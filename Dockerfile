FROM openjdk:11.0.8-jre
VOLUME /tmp
ENV SERVER_PORT=8080
COPY target/order-publisher-api.jar app.jar
ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/app.jar"]
