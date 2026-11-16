
/* =============================================================
   05_exp01_rowstore_columnstore.sql

   Proyecto: BASAV - Inteligencia de Negocios y Big Data
   Base de datos: BASAV_TTII
   Experimento: EXP-01 - Comparacion Rowstore vs Columnstore

   Objetivos:
   1. Verificar los indices de ambas estructuras.
   2. Comparar cantidad de registros y agregados.
   3. Medir 500 ejecuciones de consultas de conteo.
   4. Comparar agregaciones mensuales.
   5. Obtener estadisticas de CPU, tiempo e IO.

   Evidencias:
   E-06: Tipo de indice.
   E-07: Comparacion de registros y agregados.
   E-10: Tiempos de ejecucion de 500 consultas.

   Responsable: G. A. Quispe Vasquez

   Nota:
   Los resultados dependen de las condiciones de ejecucion,
   la cache y la carga del entorno.
   ============================================================= */

USE BASAV_TTII;
GO

/* =============================================================
   1. E-06: VERIFICACION DE INDICES
   ============================================================= */

SELECT
    OBJECT_NAME(object_id) AS tabla,
    type_desc AS tipo_indice,
    name AS nombre_indice
FROM sys.indexes
WHERE object_id IN (
    OBJECT_ID('dbo.Exp01_Rowstore'),
    OBJECT_ID('dbo.Exp01_Columnstore')
)
ORDER BY tabla, index_id;
GO

/* =============================================================
   2. E-07: COMPARACION DE REGISTROS Y AGREGADOS
   ============================================================= */

SELECT
    'Rowstore' AS estructura,
    COUNT_BIG(*) AS filas,
    SUM(PesoToneladas) AS peso_toneladas,
    SUM(Pallets) AS pallets,
    SUM(Volumen) AS volumen,
    SUM(Bultos) AS bultos
FROM dbo.Exp01_Rowstore

UNION ALL

SELECT
    'Columnstore',
    COUNT_BIG(*),
    SUM(PesoToneladas),
    SUM(Pallets),
    SUM(Volumen),
    SUM(Bultos)
FROM dbo.Exp01_Columnstore;
GO

/* =============================================================
   3. E-10: MEDICION DE 500 EJECUCIONES - ROWSTORE
   ============================================================= */

DECLARE
    @i INT = 0,
    @c BIGINT,
    @t0 DATETIME2(7) = SYSDATETIME(),
    @fin DATETIME2(7);

WHILE @i < 500
BEGIN
    SELECT @c = COUNT_BIG(*)
    FROM dbo.Exp01_Rowstore;

    SET @i += 1;
END;

SET @fin = SYSDATETIME();

SELECT
    'Rowstore' AS estructura,
    500 AS ejecuciones,
    DATEDIFF_BIG(MICROSECOND, @t0, @fin) AS tiempo_total_us,
    CAST(
        DATEDIFF_BIG(MICROSECOND, @t0, @fin) / 500.0
        AS DECIMAL(18,2)
    ) AS promedio_us;
GO

/* =============================================================
   4. E-10: MEDICION DE 500 EJECUCIONES - COLUMNSTORE
   ============================================================= */

DECLARE
    @j INT = 0,
    @d BIGINT,
    @t1 DATETIME2(7) = SYSDATETIME(),
    @fin2 DATETIME2(7);

WHILE @j < 500
BEGIN
    SELECT @d = COUNT_BIG(*)
    FROM dbo.Exp01_Columnstore;

    SET @j += 1;
END;

SET @fin2 = SYSDATETIME();

SELECT
    'Columnstore' AS estructura,
    500 AS ejecuciones,
    DATEDIFF_BIG(MICROSECOND, @t1, @fin2) AS tiempo_total_us,
    CAST(
        DATEDIFF_BIG(MICROSECOND, @t1, @fin2) / 500.0
        AS DECIMAL(18,2)
    ) AS promedio_us;
GO

/* =============================================================
   5. AGREGACION MENSUAL - ROWSTORE
   ============================================================= */

SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT
    d.Anio,
    d.Mes,
    COUNT_BIG(*) AS viajes,
    SUM(f.PesoToneladas) AS peso_toneladas,
    SUM(f.Pallets) AS pallets,
    SUM(f.Volumen) AS volumen,
    SUM(f.Bultos) AS bultos
FROM dbo.Exp01_Rowstore AS f
INNER JOIN dbo.Dim_Fecha AS d
    ON d.FechaKey = f.FechaKey
GROUP BY
    d.Anio,
    d.Mes
ORDER BY
    d.Anio,
    d.Mes;
GO

/* =============================================================
   6. AGREGACION MENSUAL - COLUMNSTORE
   ============================================================= */

SELECT
    d.Anio,
    d.Mes,
    COUNT_BIG(*) AS viajes,
    SUM(f.PesoToneladas) AS peso_toneladas,
    SUM(f.Pallets) AS pallets,
    SUM(f.Volumen) AS volumen,
    SUM(f.Bultos) AS bultos
FROM dbo.Exp01_Columnstore AS f
INNER JOIN dbo.Dim_Fecha AS d
    ON d.FechaKey = f.FechaKey
GROUP BY
    d.Anio,
    d.Mes
ORDER BY
    d.Anio,
    d.Mes;
GO

SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
GO

/* =============================================================
   FIN DEL EXPERIMENTO EXP-01
   ============================================================= */
