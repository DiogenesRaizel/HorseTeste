program project1;

{$MODE DELPHI}{$H+}

uses
  cthreads,
  SysUtils,
  Horse,
  Horse.Jhonson,
  uProdutoRepository,
  uProdutoRepositoryZeos,
  uProdutoService,
  uProdutoController,
  uWebController;

var
  LRepository: IProdutoRepository;
  LService: TProdutoService;
  LController: TProdutoController;
  LWebController: TWebController;

begin
  LRepository := nil;
  LService := nil;
  LController := nil;
  LWebController := nil;

  try
    try
      LRepository :=
        TProdutoRepositoryZeos.Create;

      LService :=
        TProdutoService.Create(
          LRepository
        );

      LController :=
        TProdutoController.Create(
          LService
        );

      LWebController :=
        TWebController.Create;

      THorse.Use(Jhonson);

      LController.RegisterRoutes;
      LWebController.RegisterRoutes;

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
    LWebController.Free;
    LController.Free;
    LService.Free;
    LRepository := nil;
  end;
end.
