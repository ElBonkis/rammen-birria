import http from "./http";
import SparkMD5 from "spark-md5";

function md5base64(file: File): Promise<string> {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onload = (event) => {
      if (event.target?.result) {
        const buffer = event.target.result as ArrayBuffer;
        const spark = new SparkMD5.ArrayBuffer();
        spark.append(buffer);
        const hashBinary = spark.end(true);
        resolve(btoa(hashBinary));
      } else {
        reject(new Error("No se pudo leer el archivo."));
      }
    };
    reader.onerror = (err) => reject(err);
    reader.readAsArrayBuffer(file);
  });
}

export async function directUpload(file: File): Promise<string> {
  const checksum = await md5base64(file);

  const { data } = await http.post("/uploads/direct", {
    filename: file.name,
    byte_size: file.size,
    content_type: file.type || "application/octet-stream",
    checksum,
  });

  const uploadUrl: string = data.direct_upload;
  const headers: Record<string, string> = data.headers;

  const res = await fetch(uploadUrl, {
    method: "PUT",
    headers,
    body: file,
  });

  if (!res.ok) {
    const text = await res.text().catch(() => "");
    throw new Error(`La subida a S3 falló (${res.status}): ${text}`);
  }

  return data.signed_id as string;
}
