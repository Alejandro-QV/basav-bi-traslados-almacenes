/* =============================================================
   05_exp01_rowstore_columnstore.sql
   Proyecto final BASAV 2026-2 - Base de datos BASAV_TTII
   Proposito : EXP-01, comparacion preliminar Rowstore vs
               Clustered Columnstore sobre las mismas columnas
   Evidencias: E-06 (Figura 6), E-07 (Figura 7), E-10 (Figura 8)
   Responsable: G. A. Quispe Vasquez
   Nota      : los tiempos varian entre ejecuciones; no se
               controla el estado de cache (ver seccion 4.7).
   ============================================================= */
USE BASAV_TTII;
GO

-- E-06 / Figura 6: tipo de indice de cada tabla de prueba
SELECT OBJECT_NAME(object_id) AS tabla, type_desc AS tipo_indice, name
FROM sys.indexes
WHERE object_id IN (OBJECT_ID('dbo.Exp01_Rowstore'), OBJECT_ID('dbo.Exp01_Columnstore'));
GO

-- E-07 / Figura 7: igualdad de conteos y agregados entre estructuras
SELECT 'Rowstore' AS est, COUNT(*) AS filas, SUM(PesoToneladas) AS peso_ton,
       SUM(Pallets) AS pallets, SUM(Volumen) AS volumen, SUM(Bultos) AS bultos
FROM dbo.Exp01_Rowstore
UNION ALL
SELECT 'Columnstore', COUNT(*), SUM(PesoToneladas), SUM(Pallets), SUM(Volumen), SUM(Bultos)
FROM dbo.Exp01_Columnstore;
GO

-- E-10 / Figura 8: 500 ejecuciones de la consulta de conteo (ejecutar cada bloque por separado)
-- Bloque Rowstore
DECLARE @i INT = 0, @c INT, @t0 DATETIME2 = SYSDATETIME();
WHILE @i < 500 BEGIN SELECT @c = COUNT(*) FROM dbo.Exp01_Rowstore; SET @i += 1; END
SELECT 'Rowstore' AS est,
       DATEDIFF_BIG(MICROSECOND, @t0, SYSDATETIME())         AS total_us,
       DATEDIFF_BIG(MICROSECOND, @t0, SYSDATETIME()) / 500.0 AS prom_us;
GO

-- Bloque Columnstore
DECLARE @j INT = 0, @d INT, @t1 DATETIME2 = SYSDATETIME();
WHILE @j < 500 BEGIN SELECT @d = COUNT(*) FROM dbo.Exp01_Columnstore; SET @j += 1; END
SELECT 'Columnstore' AS est,
       DATEDIFF_BIG(MICROSECOND, @t1, SYSDATETIME())         AS total_us,
       DATEDIFF_BIG(MICROSECOND, @t1, SYSDATETIME()) / 500.0 AS prom_us;
GO

-- PENDIENTE DE EJECUTAR: agregacion mensual en ambas estructuras.
-- Las tablas Exp01_* tienen FechaKey (no FechaCreacion), por eso se une con Dim_Fecha.
-- El JOIN interno excluye los registros sin fecha.
SET STATISTICS TIME ON;

SELECT d.Anio, d.Mes, COUNT(*) AS viajes,
       SUM(f.PesoToneladas) AS peso_ton, SUM(f.Pallets) AS pallets,
       SUM(f.Volumen) AS volumen, SUM(f.Bultos) AS bultos
FROM dbo.Exp01_Rowstore f
JOIN dbo.Dim_Fecha d ON d.FechaKey = f.FechaKey
GROUP BY d.Anio, d.Mes ORDER BY d.Anio, d.Mes;

SELECT d.Anio, d.Mes, COUNT(*) AS viajes,
       SUM(f.PesoToneladas) AS peso_ton, SUM(f.Pallets) AS pallets,
       SUM(f.Volumen) AS volumen, SUM(f.Bultos) AS bultos
FROM dbo.Exp01_Columnstore f
JOIN dbo.Dim_Fecha d ON d.FechaKey = f.FechaKey
GROUP BY d.Anio, d.Mes ORDER BY d.Anio, d.Mes;

SET STATISTICS TIME OFF;
GO
