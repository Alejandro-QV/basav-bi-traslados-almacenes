# Resultados experimentales verificados

Los valores siguientes corresponden a ejecuciones registradas en `BASAV_TTII` y no constituyen garantías de rendimiento para otros equipos.

## Estado ETL y conciliación

- `Stg_TTII_Raw`: 7,457 filas.
- `Fact_TTII`: 7,457 filas.
- `Dim_Fecha`: 67 filas.
- Último registro revisado: `EJECUTADO_CON_ADVERTENCIAS`.
- Incidencias/advertencias registradas: 58.
- Errores: 0.
- Resultado de conciliación: `CONCILIADO`.
- Se registró una regla `BULTOS_ALTO` para valores superiores a 10,000 (p99 = 8,910); se conservaron en el KPI.

## EXP-01: Rowstore vs. Columnstore

Promedios registrados en las pruebas formales de 500 ejecuciones:

| Consulta | Rowstore (µs) | Columnstore (µs) | Diferencia relativa de Columnstore |
|---|---:|---:|---:|
| Conteo | 579.72 | 157.37 | 72.9% menor |
| Agregación mensual | 6,374.89 | 784.14 | 87.7% menor |

La comparación aplica únicamente a las consultas y condiciones medidas. Los tiempos varían con caché, carga, hardware y configuración.

## EXP-02: escalabilidad sintética

| Filas generadas | Filas válidas | Filas rechazadas |
|---:|---:|---:|
| 10,000 | 9,857 | 143 |
| 100,000 | 98,517 | 1,483 |
| 1,000,000 | 985,063 | 14,937 |

Las 18 ejecuciones formales revisadas registraron estado `OK`, coincidencia de agregados y coincidencia de conteos. El piloto no se mezcló con las estadísticas formales.

## EXP-03: ETL integrado

Se revisaron seis ejecuciones formales con estado `OK`; las seis registraron 7,457 filas en staging y hechos, coincidencia de filas y coincidencia con EXP-01. Los agregados registrados fueron: peso 194590.2524 toneladas, pallets 303449.061, volumen 502825.704 y bultos 19827197.

Estos resultados son los registros revisados del proyecto. No se adjuntan archivos de datos fuente ni resultados que permitan identificar operaciones o terceros.
