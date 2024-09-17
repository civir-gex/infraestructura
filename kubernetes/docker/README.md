Despues de instalar docker verifica que este el compose y el buildx. Estos son plugins; de no encontrarlos busca en tu administrador de paquetes
Habilita BuildKit con export DOCKER_BUILDKIT=1

##### ref: https://imaginaformacion.com/tutoriales/como-reducir-el-tamano-de-una-imagen-en-docker
##### aprende docker: https://www.youtube.com/watch?v=CV_Uf3Dq-EU&t=2622s

recuerda que para subir al repositorio de dockerhub debes de etiquetar la imagan creada como:

usuario/repositorio:version

puedes usar: docker tag id_imagen usuario/repositorio:version

antes debes hacer login en tu repositorio de dockerhub

docker-compose down --rmi borra contenedores e imagenes
