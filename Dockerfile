FROM alpine:3.20
RUN apk add --no-cache openjdk17-jre
WORKDIR /app
COPY target/*.jar app.jar
EXPOSE 8080
CMD ["java","-jar","app.jar"]
