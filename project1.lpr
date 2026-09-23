program project1;

{$MODE DELPHI}{$H+}

uses
  cthreads,
  SysUtils,
  Horse,
  Horse.Jhonson,
  uDM,
  uProdutoRepository,
  uProdutoRepositoryZeos,
  uProdutoService,
  uProdutoController;

var
  LDM: TDM;
  LRepository: IProdutoRepository;
  LService: TProdutoService;
  LController: TProdutoController;

begin
  LDM := nil;
  LRepository := nil;
  LService := nil;
  LController := nil;

  try
    try
      LDM := TDM.Create(nil);

      LDM.ZConnection1.Connect;

      Writeln('Banco de dados conectado.');

      LRepository :=
        TProdutoRepositoryZeos.Create(LDM);

      LService :=
        TProdutoService.Create(
          LRepository
        );

      LController :=
        TProdutoController.Create(
          LService
        );

      THorse.Use(Jhonson);

      LController.RegisterRoutes;

      Writeln(
        'Servidor Horse iniciado na porta 9000.'
      );

      THorse.Listen(9000);

    except
      on E: Exception do
      begin
        Writeln(
          'ERRO: falha ao iniciar a aplicacao.'
        );

        Writeln(
          'Detalhes: ',
          E.Message
        );

        ExitCode := 1;
      end;
    end;

  finally
    LController.Free;
    LService.Free;
    LRepository := nil;
    LDM.Free;
  end;
end.


