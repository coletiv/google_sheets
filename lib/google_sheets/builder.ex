defmodule GoogleSheets.Builder do
  @moduledoc """
  Module responsible build sheets using the
  sheets API.
  """
  def build(:create, sheet_name) do
    %{
      properties: %{
        title: "Coletiv Google Sheets API x #{sheet_name}"
      },
      sheets: [
        %{
          properties: %{
            sheetId: 0,
            title: "Test page",
            gridProperties: %{
              frozenRowCount: 2,
              columnCount: 4
            }
          },
          data: [
            %{
              startRow: 0,
              startColumn: 0,
              rowData: [
                %{
                  values: [
                    %{
                      userEnteredValue: %{
                        stringValue: "coletiv.com\nCrafting Digital Products!"
                      },
                      effectiveValue: %{
                        stringValue: "https://www.coletiv.com/"
                      },
                      userEnteredFormat: %{
                        backgroundColor: %{
                          red: 0.102,
                          green: 0.49,
                          blue: 1
                        },
                        verticalAlignment: "MIDDLE",
                        horizontalAlignment: "CENTER",
                        wrapStrategy: "WRAP",
                        textFormat: %{
                          foregroundColor: %{
                            red: 1.0,
                            green: 1.0,
                            blue: 1.0
                          },
                          fontFamily: "Montserrat",
                          fontSize: 40,
                          bold: true
                        }
                      }
                    }
                  ]
                }
              ],
              rowMetadata: [
                %{
                  pixelSize: 275
                }
              ]
            },
            %{
              startRow: 0,
              startColumn: 2,
              columnMetadata: [
                %{
                  pixelSize: 525
                }
              ]
            },
            %{
              startRow: 1,
              startColumn: 0,
              rowData: [
                %{
                  values: sections(true)
                }
              ]
            }
          ],
          merges: [
            %{
              sheetId: 0,
              startRowIndex: 0,
              endRowIndex: 1,
              startColumnIndex: 0,
              endColumnIndex: 4
            }
          ]
        }
      ]
    }
  end

  defp sections(show?) do
    [
      sub_sections("DATE"),
      sub_sections("ARTICLE"),
      sub_sections("COMMENT"),
      sub_sections(if show?, do: "SHOW?", else: "HIDE?")
    ]
  end

  defp sub_sections(text) do
    %{
      userEnteredValue: %{
        stringValue: text
      },
      userEnteredFormat: %{
        backgroundColor: %{
          red: 0.45,
          green: 0.215,
          blue: 0.553
        },
        verticalAlignment: "MIDDLE",
        textFormat: %{
          foregroundColor: %{
            red: 1.0,
            green: 1.0,
            blue: 1.0
          },
          bold: true
        }
      }
    }
  end
end
