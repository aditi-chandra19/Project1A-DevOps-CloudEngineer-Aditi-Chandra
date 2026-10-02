package com.novapay.demo;

import com.sun.net.httpserver.Headers;
import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpServer;

import java.io.IOException;
import java.net.InetSocketAddress;
import java.nio.charset.StandardCharsets;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.atomic.LongAdder;

/**
 * Local-only NovaPay assessment simulator. It never processes or stores real payment data.
 * Failure injection is explicit and intended for safe deployment/rollback demonstrations.
 */
public final class NovaPayDemo {
    private static final String SERVICE_NAME = "novapay-demo";
    private static final String DEFAULT_VERSION = "0.1.0+local";
    private static final int MAX_REQUEST_BYTES = 16 * 1024;

    private final String version = env("NOVAPAY_VERSION", DEFAULT_VERSION);
    private final String gitSha = env("GIT_SHA", "local");
    private final String environment = env("NOVAPAY_ENVIRONMENT", "local");
    private final Map<String, LongAdder> requestCounts = new ConcurrentHashMap<>();

    private NovaPayDemo() {
    }

    public static void main(String[] args) throws IOException {
        int port = Integer.parseInt(env("PORT", "8080"));
        NovaPayDemo app = new NovaPayDemo();
        String bindAddress = env("NOVAPAY_BIND_ADDRESS", "127.0.0.1");
        HttpServer server = HttpServer.create(new InetSocketAddress(bindAddress, port), 0);
        server.createContext("/health/live", exchange -> app.handleHealth(exchange, true));
        server.createContext("/health/ready", app::handleReadiness);
        server.createContext("/version", app::handleVersion);
        server.createContext("/metrics", app::handleMetrics);
        server.createContext("/api/payments/authorize", app::handleAuthorizationSimulation);
        ExecutorService executor = Executors.newFixedThreadPool(Math.min(8,
                Math.max(2, Runtime.getRuntime().availableProcessors())));
        server.setExecutor(executor);

        Runtime.getRuntime().addShutdownHook(new Thread(() -> {
            server.stop(5);
            executor.shutdownNow();
        }, "novapay-shutdown"));
        server.start();
        System.out.printf("%s listening on %s:%d (environment=%s, version=%s)%n",
                SERVICE_NAME, bindAddress, port, app.environment, app.version);
    }

    private void handleHealth(HttpExchange exchange, boolean live) throws IOException {
        if (!requireMethod(exchange, "GET")) return;
        String route = live ? "/health/live" : "/health/ready";
        respond(exchange, 200, "application/json; charset=utf-8",
                "{\"status\":\"UP\",\"check\":\"" + (live ? "live" : "ready") + "\"}", route);
    }

    private void handleReadiness(HttpExchange exchange) throws IOException {
        if (!requireMethod(exchange, "GET")) return;
        boolean ready = Boolean.parseBoolean(env("NOVAPAY_DEMO_READY", "true"));
        respond(exchange, ready ? 200 : 503, "application/json; charset=utf-8",
                "{\"status\":\"" + (ready ? "UP" : "DOWN") + "\",\"check\":\"ready\"}",
                "/health/ready");
    }

    private void handleVersion(HttpExchange exchange) throws IOException {
        if (!requireMethod(exchange, "GET")) return;
        String body = "{\"service\":\"" + SERVICE_NAME + "\",\"version\":" + quote(version)
                + ",\"gitSha\":" + quote(gitSha) + ",\"environment\":" + quote(environment) + "}";
        respond(exchange, 200, "application/json; charset=utf-8", body, "/version");
    }

    private void handleAuthorizationSimulation(HttpExchange exchange) throws IOException {
        if (!requireMethod(exchange, "POST")) return;
        byte[] body = exchange.getRequestBody().readNBytes(MAX_REQUEST_BYTES + 1);
        if (body.length > MAX_REQUEST_BYTES) {
            respond(exchange, 413, "application/json; charset=utf-8",
                    "{\"error\":\"request_too_large\",\"simulation\":true}",
                    "/api/payments/authorize");
            return;
        }
        // This simulator deliberately discards the request body and never logs payment data.

        String failure = exchange.getRequestHeaders().getFirst("X-Demo-Failure");
        if (failure == null || failure.isBlank()) {
            respond(exchange, 202, "application/json; charset=utf-8",
                    "{\"status\":\"ACCEPTED\",\"simulation\":true,\"reference\":\"demo-only\"}",
                    "/api/payments/authorize");
            return;
        }

        switch (failure.trim().toLowerCase()) {
            case "http-500" -> respond(exchange, 500, "application/json; charset=utf-8",
                    "{\"error\":\"simulated_internal_error\",\"simulation\":true}",
                    "/api/payments/authorize");
            case "db-pool-exhaustion" -> respond(exchange, 503, "application/json; charset=utf-8",
                    "{\"error\":\"simulated_database_pool_exhaustion\",\"simulation\":true}",
                    "/api/payments/authorize");
            case "gateway-timeout" -> respond(exchange, 504, "application/json; charset=utf-8",
                    "{\"error\":\"simulated_gateway_timeout\",\"simulation\":true}",
                    "/api/payments/authorize");
            default -> respond(exchange, 400, "application/json; charset=utf-8",
                    "{\"error\":\"unknown_demo_failure\",\"simulation\":true}",
                    "/api/payments/authorize");
        }
    }

    private void handleMetrics(HttpExchange exchange) throws IOException {
        if (!requireMethod(exchange, "GET")) return;
        StringBuilder output = new StringBuilder();
        output.append("# HELP novapay_demo_http_requests_total Requests handled by the local simulator.\n")
                .append("# TYPE novapay_demo_http_requests_total counter\n");
        requestCounts.entrySet().stream().sorted(Map.Entry.comparingByKey()).forEach(entry -> {
            String[] key = entry.getKey().split("\\|", 2);
            output.append("novapay_demo_http_requests_total{route=\"").append(key[0])
                    .append("\",status=\"").append(key[1]).append("\"} ")
                    .append(entry.getValue().sum()).append('\n');
        });
        respond(exchange, 200, "text/plain; version=0.0.4; charset=utf-8", output.toString(), "/metrics");
    }

    private boolean requireMethod(HttpExchange exchange, String expected) throws IOException {
        if (expected.equals(exchange.getRequestMethod())) return true;
        exchange.getResponseHeaders().set("Allow", expected);
        respond(exchange, 405, "application/json; charset=utf-8",
                "{\"error\":\"method_not_allowed\"}", routeFor(exchange));
        return false;
    }

    private void respond(HttpExchange exchange, int status, String contentType,
                         String body, String route) throws IOException {
        byte[] bytes = body.getBytes(StandardCharsets.UTF_8);
        Headers headers = exchange.getResponseHeaders();
        headers.set("Content-Type", contentType);
        headers.set("Cache-Control", "no-store");
        headers.set("X-Content-Type-Options", "nosniff");
        requestCounts.computeIfAbsent(route + "|" + status, ignored -> new LongAdder()).increment();
        exchange.sendResponseHeaders(status, bytes.length);
        try (var output = exchange.getResponseBody()) {
            output.write(bytes);
        }
    }

    private static String routeFor(HttpExchange exchange) {
        String path = exchange.getRequestURI().getPath();
        if (path.startsWith("/api/payments/authorize")) return "/api/payments/authorize";
        return path;
    }

    private static String quote(String value) {
        StringBuilder escaped = new StringBuilder(value.length() + 2).append('"');
        for (int i = 0; i < value.length(); i++) {
            char character = value.charAt(i);
            switch (character) {
                case '"' -> escaped.append("\\\"");
                case '\\' -> escaped.append("\\\\");
                case '\b' -> escaped.append("\\b");
                case '\f' -> escaped.append("\\f");
                case '\n' -> escaped.append("\\n");
                case '\r' -> escaped.append("\\r");
                case '\t' -> escaped.append("\\t");
                default -> {
                    if (character < 0x20) {
                        escaped.append(String.format("\\u%04x", (int) character));
                    } else {
                        escaped.append(character);
                    }
                }
            }
        }
        return escaped.append('"').toString();
    }

    private static String env(String name, String fallback) {
        String value = System.getenv(name);
        return value == null || value.isBlank() ? fallback : value;
    }
}
