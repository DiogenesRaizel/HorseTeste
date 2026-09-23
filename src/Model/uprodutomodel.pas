unit uProdutoModel;

{$MODE DELPHI}{$H+}

interface

type
  TProduto = class
  private
    FId: Integer;
    FNome: string;
    FPreco: Currency;
    FEstoque: Integer;

  public
    property Id: Integer read FId write FId;
    property Nome: string read FNome write FNome;
    property Preco: Currency read FPreco write FPreco;
    property Estoque: Integer read FEstoque write FEstoque;
  end;

implementation

end.
