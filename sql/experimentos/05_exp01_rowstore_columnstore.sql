/*
BASAV_TTII - EXP-01: Rowstore vs. Columnstore
Compara conteos, agregados, consulta de conteo repetida y agregacion mensual.
Requiere: dbo.Exp01_Rowstore, dbo.Exp01_Columnstore y dbo.Dim_Fecha.
Los tiempos dependen del hardware, cache, carga y estado de la instancia.
Este script mide; no modifica ni reconstruye las tablas experimentales.
*/
USE [BASAV_TTII];
GO
SET NOCOUNT ON;
GO

-- 1. Verificar los indices de ambas estructuras.
SELECT
    OBJECT_NAME(object_id) AS tabla,
    type_desc AS tipo_indice,
    name AS nombre_indice
FROM sys.indexes
WHERE object_id IN
(
    OBJECT_ID(N'dbo.Exp01_Rowstore'),
    OBJECT_ID(N'dbo.Exp01_Columnstore')
)
ORDER BY tabla, index_id;
GO

-- 2. Comparar conteos y agregados.
SELECT
    'Rowstore' AS estructura,
    COUNT_BIG(*) AS filas,
    SUM(PesoToneladas) AS peso_ton,
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

-- 3. Medir 500 ejecuciones de conteo. Ejecutar en condiciones comparables.
DECLARE @i int = 0;
DECLARE @c bigint;
DECLARE @inicio datetime2(7) = SYSDATETIME();
DECLARE @fin datetime2(7);

WHILE @i < 500
BEGIN
    SELECT @c = COUNT_BIG(*) FROM dbo.Exp01_Rowstore;
    SET @i += 1;
END;

SET @fin = SYSDATETIME();
SELECT
    'Rowstore' AS estructura,
    DATEDIFF_BIG(MICROSECOND, @inicio, @fin) AS total_us,
    DATEDIFF_BIG(MICROSECOND, @inicio, @fin) / 500.0 AS promedio_us;
GO

DECLARE @j int = 0;
DECLARE @d bigint;
DECLARE @inicio datetime2(7) = SYSDATETIME();
DECLARE @fin datetime2(7);

WHILE @j < 500
BEGIN
    SELECT @d = COUNT_BIG(*) FROM dbo.Exp01_Columnstore;
    SET @j += 1;
END;

SET @fin = SYSDATETIME();
SELECT
    'Columnstore' AS estructura,
    DATEDIFF_BIG(MICROSECOND, @inicio, @fin) AS total_us,
    DATEDIFF_BIG(MICROSECOND, @inicio, @fin) / 500.0 AS promedio_us;
GO

-- 4. Agregacion mensual. El INNER JOIN excluye filas sin FechaKey asociada.
SET STATISTICS TIME ON;
GO

SELECT
    d.Anio,
    d.Mes,
    COUNT_BIG(*) AS viajes,
    SUM(f.PesoToneladas) AS peso_ton,
    SUM(f.Pallets) AS pallets,
    SUM(f.Volumen) AS volumen,
    SUM(f.Bultos) AS bultos
FROM dbo.Exp01_Rowstore AS f
INNER JOIN dbo.Dim_Fecha AS d
    ON d.FechaKey = f.FechaKey
GROUP BY d.Anio, d.Mes
ORDER BY d.Anio, d.Mes;
GO

SELECT
    d.Anio,
    d.Mes,
    COUNT_BIG(*) AS viajes,
    SUM(f.PesoToneladas) AS peso_ton,
    SUM(f.Pallets) AS pallets,
    SUM(f.Volumen) AS volumen,
    SUM(f.Bultos) AS bultos
FROM dbo.Exp01_Columnstore AS f
INNER JOIN dbo.Dim_Fecha AS d
    ON d.FechaKey = f.FechaKey
GROUP BY d.Anio, d.Mes
ORDER BY d.Anio, d.Mes;
GO

SET STATISTICS TIME OFF;
GO
