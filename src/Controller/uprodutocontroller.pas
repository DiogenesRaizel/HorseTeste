unit uProdutoController;

{$MODE DELPHI}{$H+}

interface

uses
  Horse,
  Horse.Jhonson,
  fpjson,
  uProdutoService,
  uDM;

type
  TProdutoController = class
  private
    class var FService: TProdutoService;

    class procedure GetProdutos(
      Req: THorseRequest;
      Res: THorseResponse); static;

    class procedure GetProduto(
      Req: THorseRequest;
      Res: THorseResponse); static;

    class procedure PostProduto(
      Req: THorseRequest;
      Res: THorseResponse); static;

    class procedure PutProduto(
      Req: THorseRequest;
      Res: THorseResponse); static;

    class procedure DeleteProduto(
      Req: THorseRequest;
      Res: THorseResponse); static;

  public
    //class procedure RegisterRoutes; static;
    class procedure RegisterRoutes(ADM: TDM); static;
  end;

implementation

uses
  SysUtils,
  uProdutoRepository,
  uProdutoRepositoryZeos;


class procedure TProdutoController.GetProdutos(
  Req: THorseRequest;
  Res: THorseResponse);
begin
  Res.ContentType('application/json');
  Res.Send(FService.Listar.AsJSON);
end;

class procedure TProdutoController.GetProduto(
  Req: THorseRequest;
  Res: THorseResponse);
var
  LId: Integer;
  LProduto: TJSONObject;
begin
  LId := StrToIntDef(Req.Params['id'], 0);

  LProduto := FService.Buscar(LId);

  if LProduto = nil then
  begin
    Res.Status(404).Send('Produto não encontrado');
    Exit;
  end;

  Res.ContentType('application/json');
  Res.Send(LProduto.AsJSON);
end;

class procedure TProdutoController.PostProduto(
  Req: THorseRequest;
  Res: THorseResponse);
var
  LProdutoEntrada: TJSONObject;
  LProduto: TJSONObject;
begin
  LProdutoEntrada := Req.Body<TJSONObject>;

  LProduto := FService.Criar(LProdutoEntrada);

  Res.Status(201);
  Res.ContentType('application/json');
  Res.Send(LProduto.AsJSON);
end;

class procedure TProdutoController.PutProduto(
  Req: THorseRequest;
  Res: THorseResponse);
var
  LId: Integer;
  LProdutoEntrada: TJSONObject;
  LProduto: TJSONObject;
begin
  LId := StrToIntDef(Req.Params['id'], 0);

  LProdutoEntrada := Req.Body<TJSONObject>;

  LProduto := FService.Atualizar(
    LId,
    LProdutoEntrada
  );

  if LProduto = nil then
  begin
    Res.Status(404).Send('Produto não encontrado');
    Exit;
  end;

  Res.ContentType('application/json');
  Res.Send(LProduto.AsJSON);
end;

class procedure TProdutoController.DeleteProduto(
  Req: THorseRequest;
  Res: THorseResponse);
var
  LId: Integer;
begin
  LId := StrToIntDef(Req.Params['id'], 0);

  if not FService.Excluir(LId) then
  begin
    Res.Status(404).Send('Produto não encontrado');
    Exit;
  end;

  Res.Status(204).Send('');
end;

class procedure TProdutoController.RegisterRoutes(ADM: TDM);
var
  LRepository: IProdutoRepository;
begin
  LRepository := TProdutoRepositoryZeos.Create(ADM);

  FService := TProdutoService.Create(
    LRepository
  );

  THorse.Get('/produtos', GetProdutos);
  THorse.Get('/produtos/:id', GetProduto);
  THorse.Post('/produtos', PostProduto);
  THorse.Put('/produtos/:id', PutProduto);
  THorse.Delete('/produtos/:id', DeleteProduto);
end;

end.
