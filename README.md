# AWS-Lambda-para-Reactividad-de-Eventos
La arquitectura descrita en el archivo main.tf utiliza Terraform para desplegar una función AWS Lambda que responde a eventos de estado de instancias EC2. Aquí tienes una breve explicación de cada componente y cómo interactúan entre sí:
Componentes de la Arquitectura
Proveedor de AWS:
provider "aws": Configura Terraform para usar AWS como proveedor de servicios en la región especificada (por defecto, us-east-1).
Rol de IAM:
aws_iam_role "lambda_exec": Define un rol de IAM llamado LambdaParaReactividadDeEventos que permite a la función Lambda asumir este rol y obtener los permisos necesarios para ejecutarse.
aws_iam_role_policy_attachment "lambda_policy": Adjunta la política AWSLambdaBasicExecutionRole al rol de IAM, otorgando permisos básicos de ejecución a la función Lambda, como la capacidad de escribir logs en CloudWatch.
Función Lambda:
aws_lambda_function "ec2_state_change": Crea una función Lambda llamada EC2StateChangeHandler que utiliza el runtime de Python 3.9. La función se define en un archivo comprimido (lambda_function_payload.zip) y se configura para usar el rol de IAM creado anteriormente. La función también tiene una variable de entorno LOG_LEVEL configurada en "INFO".
Regla de CloudWatch Events:
aws_cloudwatch_event_rule "ec2_state_change": Define una regla de CloudWatch Events llamada EC2StateChangeRule que captura eventos de cambio de estado de instancias EC2 (por ejemplo, cuando una instancia pasa a estado "running" o "stopped").
aws_cloudwatch_event_target "lambda_target": Configura la regla de CloudWatch Events para invocar la función Lambda EC2StateChangeHandler cuando se detecten eventos de cambio de estado en instancias EC2.
Permisos de Invocación de Lambda:
aws_lambda_permission "allow_cloudwatch": Otorga permisos a CloudWatch Events para invocar la función Lambda EC2StateChangeHandler.
Flujo de Trabajo
Evento de Cambio de Estado en EC2: Cuando una instancia EC2 cambia de estado (por ejemplo, de "stopped" a "running" o viceversa), se genera un evento.
Captura del Evento: La regla de CloudWatch Events EC2StateChangeRule captura este evento.
Invocación de la Función Lambda: La regla de CloudWatch Events invoca la función Lambda EC2StateChangeHandler con los detalles del evento.
Ejecución de la Función Lambda: La función Lambda procesa el evento, realiza las acciones necesarias (por ejemplo, registrar el evento) y devuelve una respuesta.
Beneficios
Automatización: Permite automatizar respuestas a cambios de estado en instancias EC2 sin intervención manual.
Escalabilidad: Utiliza la infraestructura sin servidor de AWS Lambda, que escala automáticamente según la carga.
Costos Reducidos: Aprovecha la capa gratuita de AWS para minimizar costos operativos.
Esta arquitectura es ideal para tareas de automatización y monitoreo en entornos de nube, donde es crucial responder rápidamente a cambios en el estado de los recursos.

NOTA : ARQUITECTURA PROVISIONADA EN AWS
