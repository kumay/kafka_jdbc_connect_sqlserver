FROM confluentinc/cp-server-connect-base:7.4.0

ENV CONNECT_PLUGIN_PATH="/usr/share/java,/usr/share/confluent-hub-components"

ARG JDBC_JAR_LOCATION="/usr/share/confluent-hub-components/confluentinc-kafka-connect-jdbc/lib"
ARG MYSQL_CONNECTOR_VERSION="8.0.22"

RUN confluent-hub install --no-prompt confluentinc/kafka-connect-jdbc:10.7.1 && \
    confluent-hub install --no-prompt confluentinc/kafka-connect-datagen:0.6.0 && \
    confluent-hub install --no-prompt debezium/debezium-connector-mysql:2.2.1 && \
    confluent-hub install --no-prompt debezium/debezium-connector-postgresql:2.2.1 && \
    confluent-hub install --no-prompt debezium/debezium-connector-sqlserver:2.2.1


RUN curl -k -SL "https://repo1.maven.org/maven2/mysql/mysql-connector-java/${MYSQL_CONNECTOR_VERSION}/mysql-connector-java-${MYSQL_CONNECTOR_VERSION}.jar" \
    -o "${JDBC_JAR_LOCATION}/mysql-connector-java-${MYSQL_CONNECTOR_VERSION}.jar" && \
    curl -k -SL "https://github.com/microsoft/mssql-jdbc/releases/download/v${MSSQL_JDBC_DRIVER_VERSION}/mssql-jdbc-${MSSQL_JDBC_DRIVER_VERSION}.jre${JRE_VERSION}.jar" \
    -o "${JDBC_JAR_LOCATION}/mssql-jdbc-${MSSQL_JDBC_DRIVER_VERSION}.jre${JRE_VERSION}.jar"


USER root
RUN mkdir /var/log/jfr && chmod -R ag+w /var/log/jfr
USER appuser