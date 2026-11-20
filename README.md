# BASAV-TTII: Inteligencia de Negocios y Big Data para el monitoreo de traslados entre almacenes

Proyecto académico desarrollado para el curso **Base de Datos Avanzadas y Big Data** de la Universidad Privada del Norte (UPN), periodo 2026-2.

## Información del proyecto

- **Autor:** Gabriel Alejandro Quispe Vasquez
- **Curso:** Base de Datos Avanzadas y Big Data
- **NRC:** 23814
- **Periodo:** 2026-2
- **Universidad:** Universidad Privada del Norte (UPN)
- **Carrera:** Ingeniería de Sistemas Computacionales
- **Versión de avance anterior:** `v0.1-cap-iv`

## Descripción

Solución académica de inteligencia de negocios para analizar traslados entre almacenes mediante SQL Server, procesos ETL, un modelo dimensional, consultas de indicadores y experimentos de rendimiento y escalabilidad.

El conjunto de trabajo utiliza cinco variables: **Peso, Pallets, Volumen, Bultos y Fecha de creación**. El procesamiento se ejecutó en un entorno local; el proyecto no implementa un clúster distribuido.

## Estado de implementación

| Componente | Estado documentado |
|---|---|
| Base de datos `BASAV_TTII` | Implementada |
| Modelo dimensional | Implementado |
| ETL y validación de staging | Ejecutados |
| Conciliación | Ejecutada; resultado registrado `CONCILIADO` |
| Indicadores diarios, mensuales y por turno | Implementados |
| EXP-01 Rowstore vs. Columnstore | Ejecutado; resultados formales registrados |
| EXP-02 escalabilidad sintética | Ejecutado; tres escalas registradas |
| EXP-03 ETL integrado | Ejecutado; seis ejecuciones formales registradas |
| Dashboard Power BI | Implementado; tres páginas documentadas en el informe |

## Resultados verificados

### ETL

- 7,457 registros en staging.
- 7,457 registros en `Fact_TTII`.
- 67 registros en `Dim_Fecha`.
- Última ejecución revisada: `EJECUTADO_CON_ADVERTENCIAS`.
- 58 incidencias/advertencias y 0 errores en el registro revisado.
- Resultado de conciliación: `CONCILIADO`.
- Se registró la advertencia `BULTOS_ALTO` para valores mayores a 10,000 (p99 = 8,910); esos valores se conservaron en el KPI.

### EXP-01

Promedios de las pruebas formales registradas, con 500 ejecuciones por condición:

| Consulta | Rowstore | Columnstore |
|---|---:|---:|
| Conteo | 579.72 µs | 157.37 µs |
| Agregación mensual | 6,374.89 µs | 784.14 µs |

Columnstore registró un tiempo promedio aproximadamente 72.9% menor en conteo y 87.7% menor en agregación mensual, bajo las condiciones medidas. Los resultados no deben generalizarse a otras consultas o entornos.

### EXP-02

| Escala generada | Válidas | Rechazadas |
|---:|---:|---:|
| 10,000 | 9,857 | 143 |
| 100,000 | 98,517 | 1,483 |
| 1,000,000 | 985,063 | 14,937 |

Las 18 ejecuciones formales revisadas registraron estado `OK` y coincidencia de conteos y agregados.

### EXP-03

Se revisaron seis ejecuciones formales con estado `OK`; todas registraron 7,457 filas en staging y hechos, coincidencia de filas y coincidencia con EXP-01.

El detalle se encuentra en [`resultados/README.md`](resultados/README.md).

## Estructura del repositorio

```text
basav-bi-traslados-almacenes/
├── data/
│   └── README.md
├── entorno/
│   └── README.md
├── evidencias/
│   ├── E-02_fig2_estructura_tablas.png
│   ├── E-04_fig5_entorno.png
│   ├── E-06_fig6_tipo_indice.png
│   ├── E-10_fig8_tiempos_500_ejecuciones.png
│   └── README.md
├── generador/
├── resultados/
│   └── README.md
├── sql/
│   ├── 02_trigger_auditoria.sql
│   ├── consultas/
│   │   └── 03_consultas_perfilado.sql
│   ├── experimentos/
│   │   └── 05_exp01_rowstore_columnstore.sql
│   └── legacy/
│       ├── 04_consultas_perfilado_raiz_anterior.sql
│       ├── 05_exp01_rowstore_columnstore_anterior.sql
│       └── SQLServer_BASAV_inicio_antecedente.sql
└── README.md
```

Los archivos existentes `generador/` y las evidencias históricas se conservan al aplicar esta actualización.

La exportación completa de la estructura de la instancia se conserva únicamente como referencia local y no se distribuye en este repositorio.

## Scripts SQL

- `sql/02_trigger_auditoria.sql`: trigger de auditoría. Requiere que existan `Fact_TTII` y `Log_Auditoria_Fact_TTII`.
- `sql/consultas/03_consultas_perfilado.sql`: consultas de entorno, estructura, conteos, nulos y distribución por turno.
- `sql/experimentos/05_exp01_rowstore_columnstore.sql`: medición de las estructuras Rowstore y Columnstore; no reconstruye ni elimina tablas.
- `sql/legacy/SQLServer_BASAV_inicio_antecedente.sql`: script inicial de staging e importación, conservado como antecedente histórico; no representa el ETL final.

Los scripts `SQLQuery3.sql` y `SQLQuery4.sql` fueron excluidos porque corresponden a un ejercicio independiente (`Viajes` / `Destinos`).

## Reproducción y limitaciones

El repositorio documenta los scripts y resultados del proyecto, pero **no ofrece todavía una instalación completamente reproducible desde una base de datos vacía**. No se incluye un script integral de creación de la base de datos ni se distribuyen datos fuente, backups o archivos MDF/LDF.

Para consultar el entorno ya preparado, conectar SSMS a la instancia SQL Server 2022 y seleccionar `BASAV_TTII`. Ejecutar los scripts de consulta y medición solo después de verificar que existen las tablas requeridas. No ejecutar scripts de reinicio experimental en una base con información que se quiera conservar.

## Power BI

El dashboard se encuentra documentado en el informe académico e incluye tres páginas:

1. Viajes y Magnitudes por fecha y turno.
2. Indicadores de carga por turno.
3. Tendencias y Atípicos.

Las páginas forman parte del informe académico y no se incluyen como imágenes independientes en este repositorio.

## Privacidad y seguridad

Los archivos originales de datos no se publican. No incluir nombres de personas, placas, transportistas, identificadores operativos, contraseñas, cadenas de conexión, `.bak`, `.mdf`, `.ldf`, `.xlsx` ni `.csv`.

## Herramientas

SQL Server 2022 Developer, SQL Server Management Studio 22.6, Docker, Microsoft Excel y Power BI Desktop. La declaración de uso de herramientas de IA y la autoría académica deben ajustarse a las reglas de la asignatura.

## Licencia

Material académico desarrollado para el curso Base de Datos Avanzadas y Big Data de la UPN, periodo 2026-2. Todos los derechos reservados por el autor.

Repositorio: https://github.com/Alejandro-QV/basav-bi-traslados-almacenes
