# Solución de Inteligencia de Negocios y Big Data para el monitoreo de traslados entre almacenes

Proyecto final del curso **Base de Datos Avanzadas y Big Data** (NRC 23814), periodo 2026-2.
Carrera de Ingeniería de Sistemas Computacionales, Universidad Privada del Norte (UPN).

| | |
|---|---|
| **Autor** | Gabriel Alejandro Quispe Vasquez (participación: 100 %) |
| **Docente** | Ramirez Visa Adan Elvis |
| **Versión actual** | `v0.1-cap-iv` (avance hasta el Capítulo IV del informe) |
| **Repositorio** | https://github.com/Alejandro-QV/basav-bi-traslados-almacenes |

## Descripción

El proyecto propone una solución de inteligencia de negocios para resumir viajes de programación entre almacenes por **fecha y turno**, usando cinco variables: Peso, Pallets, Volumen, Bultos y Fecha de creación. SQL Server centraliza la preparación y agregación de los datos, Power BI presentará los indicadores, y se evalúa el rendimiento con registros sintéticos de volumen creciente (10 000, 100 000 y 1 000 000 de filas).

La implementación es **local en SQL Server**; no se construye un clúster distribuido.

## Estructura del repositorio

| Carpeta | Contenido |
|---|---|
| `sql/` | Scripts T-SQL: perfilado del dataset (`04_...`) y experimento EXP-01 Rowstore vs Columnstore (`05_...`). Los scripts de DDL y ETL (`02_...`, `03_...`) se agregarán en una próxima versión. |
| `evidencias/` | Capturas de SSMS con código de evidencia (E-02, E-04, E-06, E-10), referenciadas en el informe. |
| `entorno/` | Configuración del entorno de ejecución (por completar). |
| `generador/` | Generador de datos sintéticos para EXP-02 (pendiente). |
| `resultados/` | Logs y tablas de métricas de las ejecuciones. |
| `data/` | Sin datos. Ver la sección de privacidad. |
| `docs/` | Documentación del modelo (diagrama y diccionario de datos, pendientes). |

## Entorno

- SQL Server 2022 Developer (RTM-CU25), ejecutado localmente en Docker y expuesto por el puerto 1433.
- SQL Server Management Studio (SSMS) para ejecutar los scripts.
- Base de datos: `BASAV_TTII`, con las tablas `Stg_TTII_Raw` (staging), `Dim_Fecha`, `Fact_TTII` y las copias de prueba `Exp01_Rowstore` y `Exp01_Columnstore`.
- Excel para contrastar totales de forma independiente. Power BI Desktop y Visual Studio están previstos para el dashboard y el generador sintético.

## Cómo reproducir EXP-01

1. Conectar SSMS a la instancia local de SQL Server y seleccionar la base `BASAV_TTII`.
2. Ejecutar `sql/04_consultas_perfilado.sql` para verificar entorno, estructura, conteos y distribución por turno.
3. Ejecutar `sql/05_exp01_rowstore_columnstore.sql` para comparar los tipos de índice, verificar la igualdad de agregados y medir 500 ejecuciones de la consulta de conteo en cada estructura. Cada bloque de la medición se ejecuta por separado.

Los tiempos varían entre ejecuciones y no se controla el estado de la caché; los resultados se interpretan como preliminares (ver sección 4.7 del informe).

## Estado del proyecto

- [x] Diseño de las soluciones y del experimento (Capítulos I a IV)
- [x] EXP-01: comparación preliminar Rowstore vs Columnstore sobre el dataset de trabajo
- [ ] Scripts de creación del modelo y de carga (ETL)
- [ ] EXP-02: carga y agregación sobre datos sintéticos
- [ ] EXP-03: flujo integrado y actualización del dashboard
- [ ] Dashboard en Power BI

## Privacidad y datos

El dataset original **no se publica**. El análisis usa un archivo depurado que conserva solo cinco campos numéricos y temporales; se excluyen nombres de personas, placas, transportistas y cualquier identificador. Este repositorio contiene scripts y evidencias que no incluyen datos operativos identificables. Las pruebas de volumen usan datos sintéticos generados por scripts.

El archivo `.gitignore` bloquea extensiones de datos (`.xlsx`, `.csv`, `.bak`, `.mdf`, `.ldf`).

## Uso de inteligencia artificial

Se utilizó Claude (Anthropic) como apoyo en la redacción del informe, la organización del proyecto y la elaboración de scripts T-SQL. El autor revisó y ejecutó los scripts y verificó los resultados en su propio entorno. No se ingresaron datos operativos identificables en herramientas de IA.

## Licencia

Material académico desarrollado para el curso Base de Datos Avanzadas y Big Data (UPN, 2026-2). Todos los derechos reservados por el autor.
