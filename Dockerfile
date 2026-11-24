# =====================================================================
# BuildZone - imagen para publicar en internet (Railway u otro hosting)
# ---------------------------------------------------------------------
# Etapa 1: compila el proyecto con Maven (las pruebas se corren en el PC
#          con "mvn test" antes de subir los cambios).
# Etapa 2: imagen pequena solo con Java para ejecutar, con un usuario sin
#          permisos de administrador.
# Guia: docs/DESPLIEGUE.md
# =====================================================================

# ---------- Etapa 1: compilar ----------
FROM maven:3.9-eclipse-temurin-21 AS compilacion
WORKDIR /app

# Primero solo el pom: las dependencias quedan en cache entre despliegues
COPY pom.xml .
RUN mvn -B -q dependency:go-offline

# Codigo, pagina web y scripts SQL (pom.xml los empaqueta en db/)
COPY src ./src
COPY database ./database
RUN mvn -B -q -DskipTests package && cp target/buildzone-api-*.jar /app/buildzone.jar

# ---------- Etapa 2: ejecutar ----------
FROM eclipse-temurin:21-jre
WORKDIR /app

# Usuario sin privilegios: si alguien encontrara una falla en la aplicacion,
# no tendria permisos de administrador dentro del contenedor.
RUN groupadd --system buildzone && useradd --system --gid buildzone --no-create-home buildzone
COPY --from=compilacion --chown=buildzone:buildzone /app/buildzone.jar /app/buildzone.jar
USER buildzone

# Perfil de produccion: exige claves propias (ver application-prod.properties)
ENV SPRING_PROFILES_ACTIVE=prod
# Memoria ajustada a planes pequenos (512 MB - 1 GB)
ENV JAVA_TOOL_OPTIONS="-XX:MaxRAMPercentage=75 -XX:+UseSerialGC -Xss512k -XX:+ExitOnOutOfMemoryError"

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app/buildzone.jar"]
