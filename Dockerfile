ARG MVN_VERSION="3.9.9"
ARG JAVA_VERSION="21"

FROM maven:${MVN_VERSION}-amazoncorretto-${JAVA_VERSION} AS build

WORKDIR /build
COPY ./authserver .
RUN mvn clean package -DskipTests

FROM bellsoft/liberica-openjre-alpine:${JAVA_VERSION}
WORKDIR /app
COPY --from=build /build/app/target/app-1.0-SNAPSHOT.jar .

RUN addgroup -g 1000 usergroup && \
    adduser -G usergroup -u 1000 --disabled-password user && \
    chown user:usergroup ./app-1.0-SNAPSHOT.jar && \
    chmod 550 ./app-1.0-SNAPSHOT.jar

USER user:usergroup

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "./app-1.0-SNAPSHOT.jar"]