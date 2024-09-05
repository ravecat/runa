defmodule RunaWeb.JSONAPI.Controller do
  @moduledoc """
  Constructor for JSONAPI controllers
  """

  defmacro __using__(opts) do
    serializer = Keyword.fetch!(opts, :serializer)
    context = Keyword.fetch!(opts, :context)
    schemas = Keyword.fetch!(opts, :schemas)

    context_module = Macro.expand(context, __CALLER__)

    Code.ensure_loaded(context_module)

    quote do
      alias RunaWeb.Schemas

      import OpenApiSpex.Operation,
        only: [parameter: 5, request_body: 4, response: 3]

      alias OpenApiSpex.Operation
      alias OpenApiSpex.Reference

      plug OpenApiSpex.Plug.CastAndValidate,
        render_error: RunaWeb.FallbackController

      use RunaWeb.Plugs.QueryParser, unquote(opts)

      def open_api_operation(action) do
        apply(__MODULE__, :"#{action}_operation", [])
      end

      @resource unquote(serializer).type()

      unquote(
        if function_exported?(context_module, :index, 0) do
          quote do
            def index_operation() do
              %Operation{
                tags: [@resource],
                summary: "List of current resources",
                description: "List of current resources",
                operationId: "getResourcesList",
                responses: %{
                  200 =>
                    response(
                      "200 OK",
                      Schemas.JSONAPI.Headers.content_type(),
                      unquote(schemas).IndexResponse
                    )
                }
              }
            end

            def index(
                  %{
                    assigns: %{
                      jsonapi_query: %{sort: sort, filter: filter, page: page}
                    }
                  } = conn,
                  _params
                ) do
              with {:ok, {data, meta}} <-
                     unquote(context).index(
                       sort: sort,
                       filter: filter,
                       page: page
                     ) do
                conn
                |> put_status(200)
                |> render(:index,
                  data: data,
                  meta: meta
                )
              end
            end
          end
        end
      )

      unquote(
        if function_exported?(context_module, :get, 1) do
          quote do
            def show_operation() do
              %Operation{
                tags: [@resource],
                summary: "Show of current resource",
                description: "Show of current resource",
                operationId: "getResource",
                parameters: [
                  Schemas.JSONAPI.Parameters.path()
                  | Schemas.JSONAPI.Parameters.query()
                ],
                responses: %{
                  200 =>
                    response(
                      "200 OK",
                      Schemas.JSONAPI.Headers.content_type(),
                      unquote(schemas).ShowResponse
                    )
                }
              }
            end

            def show(conn, %{id: id}) do
              with {:ok, data} <- unquote(context).get(id) do
                conn
                |> put_status(200)
                |> render(:show, data: data)
              end
            end
          end
        end
      )

      unquote(
        if function_exported?(context_module, :create, 1) do
          quote do
            def create_operation() do
              %Operation{
                tags: [@resource],
                summary: "Create new resource",
                description: "Create new resource",
                operationId: "createResource",
                requestBody:
                  request_body(
                    "Resource request body",
                    Schemas.JSONAPI.Headers.content_type(),
                    unquote(schemas).CreateBody,
                    required: true
                  ),
                responses: %{
                  201 =>
                    response(
                      "201 OK",
                      Schemas.JSONAPI.Headers.content_type(),
                      unquote(schemas).ShowResponse
                    )
                }
              }
            end

            def create(conn, _) do
              %{data: %{attributes: attrs}} = Map.get(conn, :body_params)

              with {:ok, data} <- unquote(context).create(attrs) do
                conn
                |> put_status(201)
                |> render(:show, data: data)
              end
            end
          end
        end
      )

      unquote(
        if function_exported?(context_module, :update, 2) do
          quote do
            def update_operation() do
              %Operation{
                tags: [@resource],
                summary: "Update resource",
                description: "Update resource",
                operationId: "updateResource",
                parameters: [Schemas.JSONAPI.Parameters.path()],
                requestBody:
                  request_body(
                    "Resource request body",
                    Schemas.JSONAPI.Headers.content_type(),
                    unquote(schemas).UpdateBody,
                    required: true
                  ),
                responses: %{
                  200 =>
                    response(
                      "200 OK",
                      Schemas.JSONAPI.Headers.content_type(),
                      unquote(schemas).ShowResponse
                    )
                }
              }
            end

            def update(conn, %{id: id}) do
              %{data: %{attributes: attrs}} = Map.get(conn, :body_params)

              with {:ok, data} <- unquote(context).get(id),
                   {:ok, data} <- unquote(context).update(data, attrs) do
                render(conn, :show, data: data)
              end
            end
          end
        end
      )

      unquote(
        if function_exported?(context_module, :delete, 1) do
          quote do
            def delete_operation() do
              %Operation{
                tags: [@resource],
                summary: "Delete resource",
                description: "Delete resource",
                operationId: "deleteResource",
                parameters: [Schemas.JSONAPI.Parameters.path()],
                responses: %{
                  204 => %Reference{"$ref": "#/components/responses/204"}
                }
              }
            end

            def delete(conn, %{id: id}) do
              with {:ok, data} <- unquote(context).get(id),
                   {:ok, _} <- unquote(context).delete(data) do
                conn
                |> put_status(204)
                |> render(:delete)
              end
            end
          end
        end
      )
    end
  end
end
