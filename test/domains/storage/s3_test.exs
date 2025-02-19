defmodule Runa.Storage.S3Test do
  use ExUnit.Case, async: true
  use Repatch.ExUnit

  alias Runa.Storage.S3

  setup do
    Repatch.patch(ExAws.S3, :upload, fn _stream, _bucket, _path, _opts ->
      :uploaded
    end)

    Repatch.patch(ExAws.S3.Upload, :stream_file, fn _path, _opts ->
      :streamed
    end)

    Repatch.patch(ExAws, :request, fn operation ->
      {:ok, operation}
    end)

    %{bucket: "test_bucket", path: "test/path/file"}
  end

  describe "S3 upload functionality" do
    test "opens a file stream", ctx do
      S3.upload(ctx.path, bucket: ctx.bucket)

      assert Repatch.called?(ExAws.S3.Upload, :stream_file, 1)
    end

    test "prepares upload operation", ctx do
      S3.upload(ctx.path, bucket: ctx.bucket)

      assert Repatch.called?(ExAws.S3, :upload, 4)
    end

    test "performs request to AWS", ctx do
      S3.upload(ctx.path, bucket: ctx.bucket)

      assert Repatch.called?(ExAws, :request, 1)
    end

    test "returns operation response", ctx do
      assert S3.upload(ctx.path, bucket: ctx.bucket) ==
               {:ok, :uploaded}
    end

    test "returns error", ctx do
      Repatch.patch(
        ExAws,
        :request,
        [force: true],
        fn _ ->
          {:error, :upload_failed}
        end
      )

      assert S3.upload(ctx.path, bucket: ctx.bucket) ==
               {:error, :upload_failed}
    end
  end
end
