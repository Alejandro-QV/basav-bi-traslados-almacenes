# Solución de Inteligencia de Negocios y Big Data para el monitoreo de traslados entre almacenes

## 1. Información del proyecto

- **Curso:** Base de Datos Avanzadas y Big Data
- **NRC:** 23814
- **Periodo:** 2026-2
- **Universidad:** Universidad Privada del Norte (UPN)
- **Carrera:** Ingeniería de Sistemas Computacionales
- **Autor:** Gabriel Alejandro Quispe Vasquez
- **Docente:** Ramirez Visa Adan Elvis
- **Participación:** 100 %
- **Versión de referencia:** `v0.1-cap-iv`

## 2. Descripción del proyecto

Proyecto académico orientado al diseño e implementación de una solución de inteligencia de negocios para el monitoreo de traslados entre almacenes.

La solución utiliza Microsoft SQL Server para almacenar, transformar, validar y analizar información de traslados internos. El modelo trabaja con cinco variables del conjunto de datos: Peso, Pallets, Volumen, Bultos y Fecha de creación.

La implementación contempla procesos ETL, un modelo dimensional, estructuras de almacenamiento Rowstore y Columnstore, consultas de indicadores y experimentación sobre el rendimiento de las estructuras de datos.

El entorno de ejecución es local y no contempla un clúster distribuido.

## 3. Estado de implementación

| Componente | Estado |
|---|---|
| Diseño de la solución | Implementado |
| Base de datos BASAV_TTII | Implementada |
| Modelo dimensional | Implementado |
| Proceso ETL | Implementado y ejecutado |
| Validación de staging | Ejecutada |
| Conciliación de datos | Ejecutada |
| Indicadores por turno | Implementados |
| Indicadores diarios y mensuales | Implementados |
| Experimento Rowstore vs. Columnstore | Implementación preliminar |
| Generación de datos sintéticos para EXP-02 | Pendiente de implementación |
| EXP-02 | Pendiente |
| EXP-03 | Pendiente |
| Dashboard Power BI | Pendiente de desarrollo |

## 4. Implementación ETL

La base de datos `BASAV_TTII` contiene los siguientes objetos programables:

**Función**
- `fn_turno`

**Procedimientos almacenados**
- `sp_etl_cargar_dimensiones`
- `sp_etl_cargar_hechos`
- `sp_etl_conciliar`
- `sp_etl_orquestar`
- `sp_etl_validar_staging`

**Trigger**
- `trg_auditoria_fact_traslado`

**Vistas**
- `vw_Indicadores_Diarios`
- `vw_Indicadores_Mensuales`
- `vw_kpi_turno`

Las definiciones de estos objetos se encuentran implementadas en la base de datos local. Sus scripts de creación todavía están pendientes de incorporarse al repositorio para permitir la reproducción desde una instancia nueva.

### 4.1. Última ejecución verificada

| Indicador | Resultado |
|---|---:|
| Registros en staging | 7,457 |
| Registros en Fact_TTII | 7,457 |
| Registros conciliados | 7,457 |
| Fechas en Dim_Fecha | 67 |
| Advertencias | 6 |
| Errores | 0 |
| Diferencia de peso | 0.0000 toneladas |

**Estado de ejecución:** `EJECUTADO_CON_ADVERTENCIAS`.

**Estado de conciliación:** `CONCILIADO`.

Se identificaron tres registros sin fecha de creación y sin valor de bultos. Estas condiciones fueron registradas como advertencias y no impidieron la conciliación de los registros ni de los totales de peso.

La conciliación verifica conteos, identificadores, registros faltantes, valores nulos y peso total. No representa una comparación exhaustiva de todas las columnas a nivel individual.

## 5. Experimento EXP-01: Rowstore y Columnstore

El experimento compara dos estructuras de almacenamiento:

- `Exp01_Rowstore`
- `Exp01_Columnstore`

Se implementaron consultas para:

- Verificar los tipos de índices de ambas estructuras.
- Comparar la cantidad de registros.
- Comprobar la igualdad de los agregados de peso, pallets, volumen y bultos.
- Medir 500 ejecuciones repetidas de una consulta de conteo.
- Realizar agregaciones mensuales mediante la relación con `Dim_Fecha`.

Las mediciones de rendimiento son preliminares. Los tiempos pueden variar según las condiciones de ejecución, la caché y la carga del entorno.

Las consultas de agregación mensual utilizan una unión interna con `Dim_Fecha`, por lo que excluyen los registros sin fecha de creación.

Los resultados experimentales deben interpretarse considerando estas condiciones y las evidencias correspondientes.

## 6. Tecnologías y entorno

| Tecnología | Versión / Uso |
|---|---|
| Microsoft SQL Server 2022 Developer | 16.0.4255.1 (RTM-CU25) |
| Imagen Docker | `mcr.microsoft.com/mssql/server:2022-latest` |
| Docker | 29.4.3 (build 055a478) |
| SQL Server Management Studio | 22.6.0 |
| Microsoft Excel | 16.0.20527.20088 |
| Windows | Versión 10.0.26200 |
| Power BI Desktop | Instalado; dashboard pendiente de desarrollo |

El proyecto se desarrolla en un entorno local de Windows, con SQL Server ejecutándose mediante Docker.

La etiqueta `2022-latest` de la imagen Docker puede cambiar cuando Microsoft publica actualizaciones. Por ello, también se registra la versión del motor SQL Server utilizada durante el desarrollo.

## 7. Estructura del repositorio

```text
basav-bi-traslados-almacenes/
├── data/
│   └── README.md
├── entorno/
│   └── .gitkeep
├── evidencias/
│   ├── E-02_fig2_estructura_tablas.png
│   ├── E-04_fig5_entorno.png
│   ├── E-06_fig6_tipo_indice.png
│   └── E-10_fig8_tiempos_500_ejecuciones.png
├── generador/
│   └── .gitkeep
├── resultados/
│   └── .gitkeep
├── sql/
│   ├── 04_consultas_perfilado.sql
│   └── 05_exp01_rowstore_columnstore.sql
├── .gitignore
└── README.md
```

La estructura se actualizará conforme se incorporen los scripts DDL, ETL, generación de datos sintéticos y documentación técnica.

## 8. Reproducción

Para ejecutar las consultas actualmente disponibles se requiere una instancia de SQL Server 2022 Developer y una base de datos `BASAV_TTII` previamente preparada con sus tablas y objetos.

Pasos:

1. Configurar SQL Server 2022 Developer en el entorno local.
2. Conectar SQL Server Management Studio a la instancia correspondiente.
3. Seleccionar la base de datos `BASAV_TTII`.
4. Ejecutar `sql/04_consultas_perfilado.sql` para verificar el entorno, la estructura, los conteos y la distribución por turno.
5. Ejecutar `sql/05_exp01_rowstore_columnstore.sql` para revisar los índices, comparar agregados, medir las 500 ejecuciones y realizar las agregaciones mensuales.
6. Revisar los resultados obtenidos y las evidencias disponibles en la carpeta `evidencias/`.

La reproducción completa desde una base de datos vacía todavía está pendiente de incorporar los scripts de creación del modelo, los objetos ETL y la carga de datos.

## 9. Privacidad de los datos

El conjunto de datos original no se publica en este repositorio por motivos de confidencialidad.

El proyecto trabaja con las variables Peso, Pallets, Volumen, Bultos y Fecha de creación. Se excluyen nombres de personas, placas, transportistas y otros identificadores operativos.

Los archivos originales de datos no deben incorporarse al repositorio.

Los datos sintéticos para las pruebas de volumen de EXP-02 se generarán mediante scripts T-SQL que se incorporarán al repositorio durante la implementación de dicho experimento.

## 10. Uso de herramientas de inteligencia artificial

Se utilizaron herramientas de inteligencia artificial como apoyo para la redacción del informe, la organización del proyecto y la elaboración y revisión de componentes T-SQL.

El autor es responsable de revisar, ejecutar y validar las implementaciones y los resultados presentados.

No se incorporaron datos operativos identificables en las consultas realizadas a herramientas de inteligencia artificial.

## 11. Licencia

Material académico desarrollado para el curso Base de Datos Avanzadas y Big Data de la Universidad Privada del Norte (UPN), periodo 2026-2.

Todos los derechos reservados por el autor.

---

**Repositorio:** https://github.com/Alejandro-QV/basav-bi-traslados-almacenes

**Versión de referencia:** `v0.1-cap-iv`