unit uWebController;

{$MODE DELPHI}{$H+}

interface

uses
  SysUtils,
  Horse;

type
  TWebController = class
  private
    class var FInstance: TWebController;

    class procedure GetIndex(
      Req: THorseRequest;
      Res: THorseResponse
    ); static;

    procedure DoGetIndex(
      Req: THorseRequest;
      Res: THorseResponse
    );

    function CaminhoIndex: string;

  public
    constructor Create;
    destructor Destroy; override;

    procedure RegisterRoutes;
  end;

implementation

constructor TWebController.Create;
begin
  inherited Create;

  FInstance := Self;
end;

destructor TWebController.Destroy;
begin
  if FInstance = Self then
    FInstance := nil;

  inherited Destroy;
end;

function TWebController.CaminhoIndex: string;
begin
  Result :=
    ExpandFileName(
      IncludeTrailingPathDelimiter(
        ExtractFileDir(ParamStr(0))
      ) +
      '../web/index.html'
    );
end;

class procedure TWebController.GetIndex(
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

  FInstance.DoGetIndex(
    Req,
    Res
  );
end;

procedure TWebController.DoGetIndex(
  Req: THorseRequest;
  Res: THorseResponse
);
var
  LCaminho: string;
begin
  LCaminho := CaminhoIndex;

  if not FileExists(LCaminho) then
  begin
    Res.Status(404).Send(
      'Arquivo index.html nao encontrado'
    );

    Exit;
  end;

  try
    Res.SendFile(LCaminho);
  except
    on E: Exception do
    begin
      Res.Status(500).Send(
        'Erro interno do servidor'
      );
    end;
  end;
end;

procedure TWebController.RegisterRoutes;
begin
  THorse.Get(
    '/',
    GetIndex
  );
end;

end.
