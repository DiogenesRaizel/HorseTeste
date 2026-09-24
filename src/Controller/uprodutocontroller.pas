unit uProdutoController;

{$MODE DELPHI}{$H+}

interface

uses
  Classes,
  SysUtils,
  Horse,
  Horse.Jhonson,
  fpjson,
  uProdutoModel,
  uProdutoService;

type

  TProdutoController = class
  private
    class var FInstance: TProdutoController;

    FService: TProdutoService;

    function ProdutoParaJSON(
      AProduto: TProduto
    ): TJSONObject;

    function JSONParaProduto(
      AJSON: TJSONObject
    ): TProduto;

    class procedure GetProdutos(
      Req: THorseRequest;
      Res: THorseResponse
    ); static;

    class procedure GetProduto(
      Req: THorseRequest;
      Res: THorseResponse
    ); static;

    class procedure PostProduto(
      Req: THorseRequest;
      Res: THorseResponse
    ); static;

    class procedure PutProduto(
      Req: THorseRequest;
      Res: THorseResponse
    ); static;

    class procedure DeleteProduto(
      Req: THorseRequest;
      Res: THorseResponse
    ); static;

    procedure DoGetProdutos(
      Req: THorseRequest;
      Res: THorseResponse
    );

    procedure DoGetProduto(
      Req: THorseRequest;
      Res: THorseResponse
    );

    procedure DoPostProduto(
      Req: THorseRequest;
      Res: THorseResponse
    );

    procedure DoPutProduto(
      Req: THorseRequest;
      Res: THorseResponse
    );

    procedure DoDeleteProduto(
      Req: THorseRequest;
      Res: THorseResponse
    );

  public
    constructor Create(
      AService: TProdutoService
    );

    destructor Destroy; override;

    procedure RegisterRoutes;
  end;

implementation

constructor TProdutoController.Create(
  AService: TProdutoService
);
begin
  inherited Create;

  if AService = nil then
    raise EArgumentNilException.Create(
      'Service nao pode ser nil'
    );

  FService := AService;
  FInstance := Self;
end;

destructor TProdutoController.Destroy;
begin
  if FInstance = Self then
    FInstance := nil;

  inherited Destroy;
end;

function TProdutoController.ProdutoParaJSON(
  AProduto: TProduto
): TJSONObject;
begin
  if AProduto = nil then
    raise EArgumentNilException.Create(
      'Produto nao pode ser nil'
    );

  Result := TJSONObject.Create;

  try
    Result.Add(
      'id',
      AProduto.Id
    );

    Result.Add(
      'nome',
      AProduto.Nome
    );

    Result.Add(
      'preco',
      AProduto.Preco
    );

    Result.Add(
      'estoque',
      AProduto.Estoque
    );

  except
    Result.Free;
    raise;
  end;
end;

function TProdutoController.JSONParaProduto(
  AJSON: TJSONObject
): TProduto;
begin
  if AJSON = nil then
    raise EArgumentNilException.Create(
      'JSON nao pode ser nil'
    );

  Result := TProduto.Create;

  try
    Result.Nome :=
      AJSON.Get(
        'nome',
        ''
      );

    Result.Preco :=
      AJSON.Get(
        'preco',
        0.0
      );

    Result.Estoque :=
      AJSON.Get(
        'estoque',
        0
      );

  except
    Result.Free;
    raise;
  end;
end;

class procedure TProdutoController.GetProdutos(
  Req: THorseRequest;
  Res: THorseResponse
);
begin
  if FInstance = nil then
  begin
    Res.Status(500).Send(
      'Erro interno do servidor'
    );
    Exit;
  end;

  FInstance.DoGetProdutos(
    Req,
    Res
  );
end;

procedure TProdutoController.DoGetProdutos(
  Req: THorseRequest;
  Res: THorseResponse
);
var
  LProdutos: TList;
  LJSON: TJSONArray;
  LProduto: TProduto;
  I: Integer;
begin
  LProdutos := nil;
  LJSON := nil;

  try
    //LProdutos :=
    //  FService.Listar;
    if Req.Query['busca'] <> '' then
      LProdutos := FService.Pesquisar(
      Req.Query['busca']
      )
    else
      LProdutos := FService.Listar;

    LJSON :=
      TJSONArray.Create;

if LProdutos = nil then
begin
  Res.Status(500).Send(
    'Pesquisar retornou lista nil'
  );
  Exit;
end;

Writeln(
  'Quantidade de produtos: ',
  LProdutos.Count
);

    for I := 0 to LProdutos.Count - 1 do
    begin
      LProduto :=
        TProduto(LProdutos[I]);

      try
        LJSON.Add(
          ProdutoParaJSON(LProduto)
        );
      finally
        LProduto.Free;
      end;
    end;

    Res.ContentType(
      'application/json'
    );

    Res.Status(200).Send(
      LJSON.AsJSON
    );

  except
    on E: Exception do
    begin
      Res.Status(500).Send(
        'Erro interno do servidor'
      );
    end;
  end;

  LJSON.Free;
  LProdutos.Free;
end;

class procedure TProdutoController.GetProduto(
  Req: THorseRequest;
  Res: THorseResponse
);
begin
  if FInstance = nil then
  begin
    Res.Status(500).Send(
      'Erro interno do servidor'
    );
    Exit;
  end;

  FInstance.DoGetProduto(
    Req,
    Res
  );
end;

procedure TProdutoController.DoGetProduto(
  Req: THorseRequest;
  Res: THorseResponse
);
var
  LId: Integer;
  LProduto: TProduto;
  LJSON: TJSONObject;
begin
  LProduto := nil;
  LJSON := nil;

  LId :=
    StrToIntDef(
      Req.Params['id'],
      0
    );

  if LId <= 0 then
  begin
    Res.Status(400).Send(
      'ID do produto invalido'
    );
    Exit;
  end;

  try
    LProduto :=
      FService.Buscar(LId);

    if LProduto = nil then
    begin
      Res.Status(404).Send(
        'Produto nao encontrado'
      );
      Exit;
    end;

    LJSON :=
      ProdutoParaJSON(LProduto);

    Res.ContentType(
      'application/json'
    );

    Res.Status(200).Send(
      LJSON.AsJSON
    );

  except
    on E: Exception do
    begin
      Res.Status(500).Send(
        'Erro interno do servidor'
      );
    end;
  end;

  LJSON.Free;
  LProduto.Free;
end;

class procedure TProdutoController.PostProduto(
  Req: THorseRequest;
  Res: THorseResponse
);
begin
  if FInstance = nil then
  begin
    Res.Status(500).Send(
      'Erro interno do servidor'
    );
    Exit;
  end;

  FInstance.DoPostProduto(
    Req,
    Res
  );
end;

procedure TProdutoController.DoPostProduto(
  Req: THorseRequest;
  Res: THorseResponse
);
var
  LJSONEntrada: TJSONObject;
  LProdutoEntrada: TProduto;
  LProduto: TProduto;
  LJSON: TJSONObject;
begin
  LJSONEntrada := nil;
  LProdutoEntrada := nil;
  LProduto := nil;
  LJSON := nil;

  try
    try
      LJSONEntrada :=
        Req.Body<TJSONObject>;

      if LJSONEntrada = nil then
      begin
        Res.Status(400).Send(
          'Corpo JSON invalido'
        );
        Exit;
      end;

      LProdutoEntrada :=
        JSONParaProduto(
          LJSONEntrada
        );

      LProduto :=
        FService.Criar(
          LProdutoEntrada
        );

      if LProduto = nil then
      begin
        Res.Status(500).Send(
          'Erro interno do servidor'
        );
        Exit;
      end;

      LJSON :=
        ProdutoParaJSON(
          LProduto
        );

      Res.Status(201);

      Res.ContentType(
        'application/json'
      );

      Res.Send(
        LJSON.AsJSON
      );

    except
      on E: EProdutoValidacao do
      begin
        Res.Status(400).Send(
          E.Message
        );
      end;

      on E: Exception do
      begin
        Res.Status(500).Send(
          'Erro interno do servidor'
        );
      end;
    end;

  finally
    LJSON.Free;
    LProduto.Free;
    LProdutoEntrada.Free;
  end;
end;

class procedure TProdutoController.PutProduto(
  Req: THorseRequest;
  Res: THorseResponse
);
begin
  if FInstance = nil then
  begin
    Res.Status(500).Send(
      'Erro interno do servidor'
    );
    Exit;
  end;

  FInstance.DoPutProduto(
    Req,
    Res
  );
end;

procedure TProdutoController.DoPutProduto(
  Req: THorseRequest;
  Res: THorseResponse
);
var
  LId: Integer;
  LJSONEntrada: TJSONObject;
  LProdutoEntrada: TProduto;
  LProduto: TProduto;
  LJSON: TJSONObject;
begin
  LJSONEntrada := nil;
  LProdutoEntrada := nil;
  LProduto := nil;
  LJSON := nil;

  LId :=
    StrToIntDef(
      Req.Params['id'],
      0
    );

  if LId <= 0 then
  begin
    Res.Status(400).Send(
      'ID do produto invalido'
    );
    Exit;
  end;

  try
    try
      LJSONEntrada :=
        Req.Body<TJSONObject>;

      if LJSONEntrada = nil then
      begin
        Res.Status(400).Send(
          'Corpo JSON invalido'
        );
        Exit;
      end;

      LProdutoEntrada :=
        JSONParaProduto(
          LJSONEntrada
        );

      LProduto :=
        FService.Atualizar(
          LId,
          LProdutoEntrada
        );

      if LProduto = nil then
      begin
        Res.Status(404).Send(
          'Produto nao encontrado'
        );
        Exit;
      end;

      LJSON :=
        ProdutoParaJSON(
          LProduto
        );

      Res.Status(200);

      Res.ContentType(
        'application/json'
      );

      Res.Send(
        LJSON.AsJSON
      );

    except
      on E: EProdutoValidacao do
      begin
        Res.Status(400).Send(
          E.Message
        );
      end;

      on E: Exception do
      begin
        Res.Status(500).Send(
          'Erro interno do servidor'
        );
      end;
    end;

  finally
    LJSON.Free;
    LProduto.Free;
    LProdutoEntrada.Free;
  end;
end;

class procedure TProdutoController.DeleteProduto(
  Req: THorseRequest;
  Res: THorseResponse
);
begin
  if FInstance = nil then
  begin
    Res.Status(500).Send(
      'Erro interno do servidor'
    );
    Exit;
  end;

  FInstance.DoDeleteProduto(
    Req,
    Res
  );
end;

procedure TProdutoController.DoDeleteProduto(
  Req: THorseRequest;
  Res: THorseResponse
);
var
  LId: Integer;
begin
  LId :=
    StrToIntDef(
      Req.Params['id'],
      0
    );

  if LId <= 0 then
  begin
    Res.Status(400).Send(
      'ID do produto invalido'
    );
    Exit;
  end;

  try
    if not FService.Excluir(LId) then
    begin
      Res.Status(404).Send(
        'Produto nao encontrado'
      );
      Exit;
    end;

    Res.Status(204);

  except
    on E: Exception do
    begin
      Res.Status(500).Send(
        'Erro interno do servidor'
      );
    end;
  end;
end;

procedure TProdutoController.RegisterRoutes;
begin
  THorse.Get(
    '/produtos',
    GetProdutos
  );

  THorse.Get(
    '/produtos/:id',
    GetProduto
  );

  THorse.Post(
    '/produtos',
    PostProduto
  );

  THorse.Put(
    '/produtos/:id',
    PutProduto
  );

  THorse.Delete(
    '/produtos/:id',
    DeleteProduto
  );
end;

end.


