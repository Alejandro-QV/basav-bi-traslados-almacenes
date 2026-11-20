/*
BASAV_TTII - Trigger de auditoria de Fact_TTII
Requiere: dbo.Fact_TTII y dbo.Log_Auditoria_Fact_TTII existentes.
Seguro para volver a ejecutar: CREATE OR ALTER TRIGGER.
*/
USE [BASAV_TTII];
GO

IF OBJECT_ID(N'dbo.Fact_TTII', N'U') IS NULL
    THROW 50001, 'No existe dbo.Fact_TTII. Cree primero la estructura de la base.', 1;
GO

IF OBJECT_ID(N'dbo.Log_Auditoria_Fact_TTII', N'U') IS NULL
    THROW 50002, 'No existe dbo.Log_Auditoria_Fact_TTII. Cree primero la estructura de auditoria.', 1;
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER TRIGGER [dbo].[trg_auditoria_fact_traslado]
ON [dbo].[Fact_TTII]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.Log_Auditoria_Fact_TTII
    (
        Operacion,
        IdHecho,
        IdCargaAnterior,
        IdCargaNuevo,
        FechaKeyAnterior,
        FechaKeyNuevo,
        PesoAnterior,
        PesoNuevo,
        PalletsAnterior,
        PalletsNuevo,
        VolumenAnterior,
        VolumenNuevo,
        BultosAnterior,
        BultosNuevo
    )
    SELECT
        CASE
            WHEN D.IdHecho IS NULL THEN 'INSERT'
            WHEN I.IdHecho IS NULL THEN 'DELETE'
            ELSE 'UPDATE'
        END,
        COALESCE(I.IdHecho, D.IdHecho),
        D.IdCarga,
        I.IdCarga,
        D.FechaKey,
        I.FechaKey,
        D.PesoToneladas,
        I.PesoToneladas,
        D.Pallets,
        I.Pallets,
        D.Volumen,
        I.Volumen,
        D.Bultos,
        I.Bultos
    FROM inserted AS I
    FULL OUTER JOIN deleted AS D
        ON I.IdHecho = D.IdHecho;
END;
GO

ALTER TABLE [dbo].[Fact_TTII]
ENABLE TRIGGER [trg_auditoria_fact_traslado];
GO
