unit uProdutoRepository;

{$MODE DELPHI}{$H+}

interface

uses
  fpjson;

type
  IProdutoRepository = interface
    ['{1F3A080D-8A69-4101-9BB1-419651E34F06}']

    function Listar: TJSONArray;

    function Buscar(
      AId: Integer): TJSONObject;

    function Inserir(
      AProduto: TJSONObject): TJSONObject;

    function Atualizar(
      AId: Integer;
      AProduto: TJSONObject): TJSONObject;

    function Excluir(
      AId: Integer): Boolean;
  end;

implementation

end.
