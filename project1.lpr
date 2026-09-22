program project1;

{$MODE DELPHI}{$H+}

uses
  cthreads,
  SysUtils,
  Horse,
  Horse.Jhonson,
  uProdutoController,
  uDM;

begin
  DM := TDM.Create(nil);

  try
    try
      DM.ZConnection1.Connect;

      Writeln('Banco de dados conectado.');

      THorse.Use(Jhonson);
      TProdutoController.RegisterRoutes(DM);

      Writeln('Servidor Horse iniciado na porta 9000.');

      THorse.Listen(9000);

    except
      on E: Exception do
      begin
        Writeln('ERRO: falha ao iniciar a aplicacao.');
        Writeln('Detalhes: ', E.Message);
        Halt(1);
      end;
    end;

  finally
    DM.Free;
  end;
end.
