defmodule MillionNumbersWeb.NumbersController do
  use MillionNumbersWeb, :controller

  def source(conn, _params) do
    {:ok, foo_conn} =
      Postgrex.start_link(
        hostname: "localhost",
        username: "postgres",
        password: "postgres",
        database: "foo"
      )

    conn =
      conn
      |> put_resp_content_type("text/event-stream")
      |> send_chunked(200)

    send_chunks(conn, foo_conn, "source")
  end

  def dest(conn, _params) do
    {:ok, foo_conn} =
      Postgrex.start_link(
        hostname: "localhost",
        username: "postgres",
        password: "postgres",
        database: "bar"
      )

    conn =
      conn
      |> put_resp_content_type("text/event-stream")
      |> send_chunked(200)

    send_chunks(conn, foo_conn, "dest")
  end

  defp send_chunks(conn, db_conn, table_name) do
    numbers_range = MillionNumbers.Populator.numbers_range()
    chunk_size = 10_000

    numbers_range
    |> Enum.take_every(chunk_size)
    |> Enum.each(fn tab ->
      source_chunk =
        Postgrex.query!(db_conn, "SELECT * FROM #{table_name} ORDER BY a LIMIT $1 OFFSET $2", [
          chunk_size,
          tab - 1
        ])

      csv_chunk =
        Enum.reduce(source_chunk.rows, "", fn row, acc -> acc <> Enum.join(row, ", ") <> "\n" end)

      conn |> chunk(csv_chunk)
    end)

    conn
  end
end
