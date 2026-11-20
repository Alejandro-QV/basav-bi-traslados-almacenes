/*
Proyecto BASAV - inicio SQL Server
Paso 1: crear la base y una tabla de staging para importar el Excel de 5 columnas.
Importa primero a dbo.Stg_TTII_Raw; después ejecuta el bloque de validación.
No se incluyen nombres, transportistas ni placas.
*/

IF DB_ID(N'BASAV_TTII') IS NULL
    CREATE DATABASE BASAV_TTII;
GO
USE BASAV_TTII;
GO

IF OBJECT_ID(N'dbo.Stg_TTII_Raw', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Stg_TTII_Raw
    (
        IdCarga       bigint IDENTITY(1,1) NOT NULL PRIMARY KEY,
        Peso          nvarchar(50) NULL,
        Pallets       nvarchar(50) NULL,
        Volumen       nvarchar(50) NULL,
        Bultos        nvarchar(50) NULL,
        [Fecha creación] nvarchar(50) NULL
    );
END;
GO

/* Revisión inicial después de importar el Excel */
SELECT COUNT(*) AS FilasImportadas
FROM dbo.Stg_TTII_Raw;
GO

SELECT TOP (20)
    Peso, Pallets, Volumen, Bultos, [Fecha creación]
FROM dbo.Stg_TTII_Raw
ORDER BY IdCarga;
GO

/* Diagnóstico de conversión: identifica filas con fecha/números inválidos.
   Los estilos 103 y 120 contemplan dd/mm/yyyy y yyyy-mm-dd hh:mi:ss. */
WITH Normalizados AS
(
    SELECT
        IdCarga,
        TRY_CONVERT(decimal(18,3), REPLACE(LTRIM(RTRIM(Peso)), ',', '.')) AS PesoNum,
        TRY_CONVERT(decimal(18,3), REPLACE(LTRIM(RTRIM(Pallets)), ',', '.')) AS PalletsNum,
        TRY_CONVERT(decimal(18,3), REPLACE(LTRIM(RTRIM(Volumen)), ',', '.')) AS VolumenNum,
        TRY_CONVERT(int, LTRIM(RTRIM(Bultos))) AS BultosNum,
        COALESCE(
            TRY_CONVERT(datetime2(0), [Fecha creación], 103),
            TRY_CONVERT(datetime2(0), [Fecha creación], 120),
            TRY_CONVERT(datetime2(0), [Fecha creación], 121)
        ) AS FechaNum
    FROM dbo.Stg_TTII_Raw
)
SELECT *
FROM Normalizados
WHERE PesoNum IS NULL
   OR PalletsNum IS NULL
   OR VolumenNum IS NULL
   OR BultosNum IS NULL
   OR FechaNum IS NULL
ORDER BY IdCarga;
GO

/*
Siguiente etapa (todavía no ejecutar como resultados finales):
1. Revisar las filas que devuelve el diagnóstico.
2. Crear DimFecha y FactViaje.
3. Cargar datos válidos con un procedimiento ETL.
4. Comparar conteos y sumas contra Excel.
5. Medir tiempos con 10k, 100k y 1M registros.
*/
