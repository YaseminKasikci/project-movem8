# ----- Build stage -----
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app

# Copie minimale pour le cache Maven
COPY pom.xml ./
# si tu utilises le wrapper, décommente les 2 lignes suivantes
# COPY .mvn/ .mvn/
# COPY mvnw mvnw
RUN mvn -q -DskipTests dependency:go-offline

# Copie du code et build
COPY src ./src
RUN mvn -q -DskipTests package

# ----- Runtime stage -----
FROM eclipse-temurin:17-jre
WORKDIR /app

# (facultatif) timezone & UTF-8
ENV TZ=Europe/Paris \
    LANG=C.UTF-8

# Options JVM (peut aussi être passé via compose)
ENV JAVA_OPTS=""

# Copie du jar produit
COPY --from=build /app/target/*.jar app.jar

EXPOSE 8080

# Laisse Spring se configurer via les variables d'env fournies par docker-compose
ENTRYPOINT ["sh","-c","java $JAVA_OPTS -jar /app/app.jar"]
