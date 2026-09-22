unit uProdutoService;

{$MODE DELPHI}{$H+}

interface

uses
  fpjson,
  uProdutoRepository;

type
  TProdutoService = class
  private
    FRepository: IProdutoRepository;

  public
    constructor Create(
      const ARepository: IProdutoRepository);

    function Listar: TJSONArray;

    function Buscar(
      AId: Integer): TJSONObject;

    function Criar(
      AEntrada: TJSONObject): TJSONObject;

    function Atualizar(
      AId: Integer;
      AEntrada: TJSONObject): TJSONObject;

    function Excluir(
      AId: Integer): Boolean;
  end;

implementation

constructor TProdutoService.Create(
  const ARepository: IProdutoRepository);
begin
  inherited Create;

  FRepository := ARepository;
end;

function TProdutoService.Listar: TJSONArray;
begin
  Result := FRepository.Listar;
end;

function TProdutoService.Buscar(
  AId: Integer): TJSONObject;
begin
  Result := FRepository.Buscar(AId);
end;

function TProdutoService.Criar(
  AEntrada: TJSONObject): TJSONObject;
begin
  Result := FRepository.Inserir(AEntrada);
end;

function TProdutoService.Atualizar(
  AId: Integer;
  AEntrada: TJSONObject): TJSONObject;
begin
  Result := FRepository.Atualizar(
    AId,
    AEntrada
  );
end;

function TProdutoService.Excluir(
  AId: Integer): Boolean;
begin
  Result := FRepository.Excluir(AId);
end;

end.
