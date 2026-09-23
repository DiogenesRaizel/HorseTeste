unit uProdutoService;

{$MODE DELPHI}{$H+}

interface

uses
  Classes,
  SysUtils,
  uProdutoRepository,
  uProdutoModel;

type

  EProdutoValidacao = class(Exception);

  TProdutoService = class
  private
    FRepository: IProdutoRepository;

    procedure ValidarProduto(
      AProduto: TProduto
    );

  public
    constructor Create(
      const ARepository: IProdutoRepository
    );

    function Listar: TList;

    function Buscar(
      AId: Integer
    ): TProduto;

    function Criar(
      AProduto: TProduto
    ): TProduto;

    function Atualizar(
      AId: Integer;
      AProduto: TProduto
    ): TProduto;

    function Excluir(
      AId: Integer
    ): Boolean;
  end;

implementation

constructor TProdutoService.Create(
  const ARepository: IProdutoRepository
);
begin
  inherited Create;

  FRepository := ARepository;
end;

procedure TProdutoService.ValidarProduto(
  AProduto: TProduto
);
begin
  if AProduto = nil then
    raise EProdutoValidacao.Create(
      'Produto invalido'
    );

  if Trim(AProduto.Nome) = '' then
    raise EProdutoValidacao.Create(
      'Nome do produto e obrigatorio'
    );

  if AProduto.Preco < 0 then
    raise EProdutoValidacao.Create(
      'Preco nao pode ser negativo'
    );

  if AProduto.Estoque < 0 then
    raise EProdutoValidacao.Create(
      'Estoque nao pode ser negativo'
    );
end;

function TProdutoService.Listar: TList;
begin
  Result :=
    FRepository.Listar;
end;

function TProdutoService.Buscar(
  AId: Integer
): TProduto;
begin
  Result :=
    FRepository.Buscar(AId);
end;

function TProdutoService.Criar(
  AProduto: TProduto
): TProduto;
begin
  ValidarProduto(AProduto);

  Result :=
    FRepository.Inserir(AProduto);
end;

function TProdutoService.Atualizar(
  AId: Integer;
  AProduto: TProduto
): TProduto;
begin
  if AId <= 0 then
    raise EProdutoValidacao.Create(
      'ID do produto invalido'
    );

  ValidarProduto(AProduto);

  Result :=
    FRepository.Atualizar(
      AId,
      AProduto
    );
end;

function TProdutoService.Excluir(
  AId: Integer
): Boolean;
begin
  if AId <= 0 then
    raise EProdutoValidacao.Create(
      'ID do produto invalido'
    );

  Result :=
    FRepository.Excluir(AId);
end;

end.
