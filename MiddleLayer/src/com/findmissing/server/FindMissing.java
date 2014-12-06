package com.findmissing.server;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

import javax.ws.rs.Consumes;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.sun.jersey.core.header.FormDataContentDisposition;
import com.sun.jersey.multipart.FormDataParam;

@Path("/findmissing")
public class FindMissing {

	static long requestid = 0;

	@POST
	@Path("/findperson")
	@Consumes(MediaType.MULTIPART_FORM_DATA)
	@Produces(MediaType.APPLICATION_JSON)
	public String uploadFile(
			@FormDataParam("image") InputStream fileInputStream,
			@FormDataParam("image") FormDataContentDisposition contentDispositionHeader,
			@FormDataParam("name") String personName)
			throws JSONException, IOException {
		System.out.println(personName);
		// String filePath = contentDispositionHeader.getFileName();
		saveFile(fileInputStream, "test.jpg");
		System.out.println("File saved to server location : " + "test");
		JSONObject obj = new JSONObject();
		JSONArray jsonArray = new JSONArray();
		obj.put("requestid", requestid);
		obj.put("matchesfound", 2);
		obj.put("matchesinfo", jsonArray);

		JSONObject match1 = new JSONObject();
		match1.put("accuracy", 80);
		match1.put("personid", 1);
		match1.put("images", new String[]{"res/test.jpg", "res/test.jpg", "res/test.jpg", "res/test.jpg", "res/test.jpg"});

		JSONObject match2 = new JSONObject();
		match2.put("accuracy", 70);
		match2.put("personid", 2);
		match2.put("images", new String[]{"res/test.jpg", "res/test.jpg", "res/test.jpg", "res/test.jpg", "res/test.jpg"});

		jsonArray.put(match1);
		jsonArray.put(match2);
		return obj.toString();

	}

	@GET
	@Path("/test")
	@Produces(MediaType.APPLICATION_JSON)
	public String test() throws JSONException{
		JSONObject obj = new JSONObject();
		obj.put("result", "success");
		return obj.toString();
	}

	// save uploaded file to a defined location on the server
	private void saveFile(InputStream uploadedInputStream, String serverLocation) throws IOException {
		try {
			OutputStream outpuStream = new FileOutputStream(new File(
					serverLocation));
			int read = 0;
			byte[] bytes = new byte[1024];
			while ((read = uploadedInputStream.read(bytes)) != -1) {
				outpuStream.write(bytes, 0, read);
			}
			outpuStream.flush();
			outpuStream.close();
		} catch (IOException e) {

			e.printStackTrace();
		}

	}

}
