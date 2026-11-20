/* =============================================================
   04_consultas_perfilado.sql
   Proyecto final BASAV 2026-2 - Base de datos BASAV_TTII
   Proposito : verificar entorno, estructura, conteos y turnos
   Evidencias: E-04 (Figura 5), E-02 (Figuras 2, 3 y 4)
   Responsable: G. A. Quispe Vasquez
   ============================================================= */
USE BASAV_TTII;
GO

-- E-04 / Figura 5: version de SQL Server, base activa y tablas
SELECT @@VERSION AS version_sql, DB_NAME() AS base_actual, SYSDATETIME() AS fecha_ejecucion;
SELECT name AS tabla FROM sys.tables ORDER BY name;
GO

-- E-02 / Figura 2: estructura de columnas de las tablas del modelo
SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME IN ('Stg_TTII_Raw','Dim_Fecha','Fact_TTII','Exp01_Rowstore','Exp01_Columnstore')
ORDER BY TABLE_NAME, ORDINAL_POSITION;
GO

-- E-02 / Figura 3: conteo de registros por tabla y nulos en staging
SELECT 'Stg_TTII_Raw' AS tabla, COUNT(*) AS filas FROM dbo.Stg_TTII_Raw
UNION ALL SELECT 'Fact_TTII',         COUNT(*) FROM dbo.Fact_TTII
UNION ALL SELECT 'Exp01_Rowstore',    COUNT(*) FROM dbo.Exp01_Rowstore
UNION ALL SELECT 'Exp01_Columnstore', COUNT(*) FROM dbo.Exp01_Columnstore;

SELECT
  SUM(CASE WHEN FechaCreacion IS NULL THEN 1 ELSE 0 END) AS sin_fecha,
  SUM(CASE WHEN Bultos        IS NULL THEN 1 ELSE 0 END) AS sin_bultos
FROM dbo.Stg_TTII_Raw;
GO

-- E-02 / Figura 4: viajes y totales por turno
-- Turno 1: 07:00-14:59 | Turno 2: 15:00-22:59 | Turno 3: 23:00-06:59
SELECT
  CASE WHEN DATEPART(HOUR, FechaCreacion) BETWEEN 7  AND 14 THEN 'Turno 1'
       WHEN DATEPART(HOUR, FechaCreacion) BETWEEN 15 AND 22 THEN 'Turno 2'
       ELSE 'Turno 3' END AS turno,
  COUNT(*)      AS viajes,
  SUM(Peso)     AS peso,
  SUM(Pallets)  AS pallets,
  SUM(Volumen)  AS volumen,
  SUM(Bultos)   AS bultos
FROM dbo.Stg_TTII_Raw
WHERE FechaCreacion IS NOT NULL
GROUP BY CASE WHEN DATEPART(HOUR, FechaCreacion) BETWEEN 7  AND 14 THEN 'Turno 1'
              WHEN DATEPART(HOUR, FechaCreacion) BETWEEN 15 AND 22 THEN 'Turno 2'
              ELSE 'Turno 3' END
ORDER BY turno;
GO
