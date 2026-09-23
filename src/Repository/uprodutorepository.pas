unit uProdutoRepository;

{$MODE DELPHI}{$H+}

interface

uses
  Classes,
  uProdutoModel;

type
  IProdutoRepository = interface
    ['{23F93AFE-6091-47F1-9A14-D7C780557503}']

    function Listar: TList;
    function Buscar(AId: Integer): TProduto;
    function Inserir(AProduto: TProduto): TProduto;
    function Atualizar(AId: Integer; AProduto: TProduto): TProduto;
    function Excluir(AId: Integer): Boolean;
  end;

implementation

end.
