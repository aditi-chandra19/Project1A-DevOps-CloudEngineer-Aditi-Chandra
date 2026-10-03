FROM eclipse-temurin:21-jdk AS build

WORKDIR /workspace

COPY src/main/java/com/novapay/demo/NovaPayDemo.java .

RUN javac --release 21 --add-modules jdk.httpserver -d classes NovaPayDemo.java \
    && jar --create --file novapay-demo.jar \
        --main-class com.novapay.demo.NovaPayDemo \
        -C classes .

FROM eclipse-temurin:21-jre

WORKDIR /app

COPY --from=build --chown=10001:10001 /workspace/novapay-demo.jar /app/app.jar

USER 10001:10001

ENV PORT=8080 \
    NOVAPAY_BIND_ADDRESS=0.0.0.0 \
    NOVAPAY_VERSION=0.1.0 \
    GIT_SHA=local

EXPOSE 8080

ENTRYPOINT ["java", "--add-modules", "jdk.httpserver", "-jar", "/app/app.jar"]
