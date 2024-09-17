FROM ubuntu:20.04

# creando usuario mssql
RUN useradd -u 10001 mssql

# instalando SQL Server
RUN apt-get update && apt-get install -y wget software-properties-common apt-transport-https
RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN add-apt-repository "$(wget -qO- https://packages.microsoft.com/config/ubuntu/20.04/mssql-server-2022.list)"
RUN apt-get update
RUN apt-get install -y mssql-server

# creando directorios de trabajo
RUN mkdir /var/opt/sqlserver
RUN mkdir /var/opt/sqlserver/data
RUN mkdir /var/opt/sqlserver/log
RUN mkdir /var/opt/sqlserver/backup


# estableciendo permisos a directorios
RUN chown -R mssql:mssql /var/opt/sqlserver
RUN chown -R mssql:mssql /var/opt/mssql

# instalando SSIS
RUN apt-get install -y mssql-server-is
RUN echo  "[TELEMETRY]\nenabled = F" > /var/opt/ssis/ssis.conf
RUN cat /var/opt/ssis/ssis.conf
RUN SSIS_PID=Developer ACCEPT_EULA=Y /opt/ssis/bin/ssis-conf -n setup

# limpieza de la imagen
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# cambiando al usuario mssql
USER mssql

# iniciando SQL Server
CMD /opt/mssql/bin/sqlservr
