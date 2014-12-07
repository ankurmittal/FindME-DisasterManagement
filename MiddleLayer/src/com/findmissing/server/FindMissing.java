package com.findmissing.server;

import java.awt.Graphics2D;
import java.awt.geom.AffineTransform;
import java.awt.image.BufferedImage;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.util.Collection;

import javax.imageio.ImageIO;
import javax.ws.rs.Consumes;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.findmissing.db.DummyDB;
import com.findmissing.db.DummyDataHelper;
import com.sun.jersey.api.client.Client;
import com.sun.jersey.api.client.WebResource;
import com.sun.jersey.api.client.config.ClientConfig;
import com.sun.jersey.api.client.config.DefaultClientConfig;
import com.sun.jersey.core.header.FormDataContentDisposition;
import com.sun.jersey.multipart.FormDataParam;

@Path("/findmissing")
public class FindMissing {

	static String apacheDest = "D:/Program Files (x86)/Apache Software Foundation/Apache2.2/htdocs/jquery.facedetection/";

	static long requestid = 0;

	static DummyDB db;

	static {
		db = new DummyDB();
		System.out.println("test");
		DummyDataHelper.insertDummyData(1000, db);
	    //Display 'hello world' just like when using the demo

	}

	private void delete(String path) {
		File file = new File(path);
		if(file.exists())
			file.delete();
	}


	@POST
	@Path("/findperson")
	@Consumes(MediaType.MULTIPART_FORM_DATA)
	@Produces(MediaType.APPLICATION_JSON)
	public String uploadFile(
			@FormDataParam("image") InputStream fileInputStream,
			@FormDataParam("image") FormDataContentDisposition contentDispositionHeader,
			@FormDataParam("name") String filename)
			throws JSONException, IOException, InterruptedException {

		System.out.println(filename);

		String lowerAPIURL = "http://localhost:8000/polls/matchPerson";
		// String filePath = contentDispositionHeader.getFileName();
		String imageName = filename.equals("") ? "test" + requestid + ".jpg" : filename;
		String htmlfile = "test" + requestid + ".html";
		BufferedImage imBuff = ImageIO.read(fileInputStream);
		double scaleFactor = 0.3;
		imBuff = scale(imBuff, imBuff.getType(), (int)(imBuff.getWidth()*scaleFactor),
				(int)(imBuff.getHeight()*scaleFactor), scaleFactor, scaleFactor);
		File outI = new File(apacheDest + imageName);
		System.out.println(outI);
		createHTML(apacheDest + htmlfile, imageName);
		ImageIO.write(imBuff, "jpg", outI);
		//saveFile(fileInputStream, apacheDest + imageName);

		System.out.println("File saved to server location : " + "test");
		JSONObject imageCrop = detectFace(htmlfile);
		requestid++;
		JSONObject obj = new JSONObject();
		if(imageCrop == null /*|| imageCrop.getDouble("confidence") < -1.5*/){
			System.out.println("Error during face detection");
			obj.put("response", "error");
			obj.put("desc", "Error during face detection");
			return obj.toString();
		}
		//delete(apacheDest + htmlfile);
		//delete(apacheDest + imageName);
		System.out.println(imageCrop);

		//
		ClientConfig cc = new DefaultClientConfig();
	    cc.getProperties().put(
	        ClientConfig.PROPERTY_FOLLOW_REDIRECTS, true);
	    Client c = Client.create(cc);
	    WebResource r = c.resource(lowerAPIURL);
	    String response = r.queryParam("img_name", imageName)
	    	.queryParam("pos_x", imageCrop.getDouble("x") + "")
	    	.queryParam("pos_y", imageCrop.getDouble("y") + "")
	    	.queryParam("width", imageCrop.getDouble("width") + "")
	    	.queryParam("height", imageCrop.getDouble("height") + "")
	    	.accept(MediaType.APPLICATION_JSON)
	    	.get(String.class);
	    System.out.println("Response from python: \n" + response);
	    JSONObject respObj = new JSONObject(response);
	    JSONArray respArray = respObj.getJSONArray("info");


		JSONArray jsonArray = new JSONArray();

		int resulttoreturn = respObj.getInt("matches");
		obj.put("requestid", requestid - 1);
		obj.put("response", "success");
		obj.put("matchesfound", resulttoreturn);
		obj.put("matchesinfo", jsonArray);
		JSONObject info = null;
		JSONArray urls = null;
		if(resulttoreturn > 0) {
			info = respArray.getJSONObject(0);
			urls = info.getJSONArray("urls");
		}
		for(int i = 0; i < resulttoreturn; i++){
			JSONObject match = new JSONObject();
			String url = urls.getString(i);
			match.put("personname", getNameFromURL(url));
			match.put("images", new String[]{urls.getString(i)});
			jsonArray.put(match);
		}
		return obj.toString();
	}

	private String getNameFromURL(String url) {
		int start = 0, end = 0;
		for(int i = 0; i < url.length(); i++){
			if(url.charAt(i) == '/') {
				start = end;
				end = i;
			}
		}
		return url.substring(start, end);
	}


	public static BufferedImage scale(BufferedImage sbi, int imageType, int dWidth, int dHeight, double fWidth, double fHeight) {
	    BufferedImage dbi = null;
	    if(sbi != null) {
	        dbi = new BufferedImage(dWidth, dHeight, imageType);
	        Graphics2D g = dbi.createGraphics();
	        AffineTransform at = AffineTransform.getScaleInstance(fWidth, fHeight);
	        g.drawRenderedImage(sbi, at);
	    }
	    return dbi;
	}

	private void createHTML(String filename, String imageName) throws IOException {
		String html = "<html>\n<head>\n<script src=\"http://ajax.googleapis.com/ajax/libs/jquery/2.1.1/jquery.min.js\"></script>\n"
				+ "<script src=\"jquery.facedetection.min.js\"></script>\n</head>\n<body>\n<img id=\"picture\" src=\"" + imageName + "\">\n</body>\n</html>";
		OutputStream outpuStream = new FileOutputStream(new File(
				filename));
		outpuStream.write(html.getBytes());
		outpuStream.flush();
		outpuStream.close();
	}

	private JSONObject detectFace(String htmlfile) throws IOException, InterruptedException, JSONException
	{
		Process process = Runtime.getRuntime().exec("D:/phantomjs/phantomjs.exe D:/phantomjs/load.js " + htmlfile);
	    int exitStatus = process.waitFor();
	    BufferedReader bufferedReader = new BufferedReader(new InputStreamReader (process.getInputStream()));

	    String currentLine=null;
	    if(exitStatus != 0)
	    	return null;
	    currentLine= bufferedReader.readLine();
	    System.out.println(currentLine);
	    if(currentLine.equalsIgnoreCase("No Face"))
	    	return null;

	    JSONObject obj = new JSONObject(currentLine);
	    return obj;
	}

	@GET
	@Path("/test")
	@Produces(MediaType.APPLICATION_JSON)
	public String test() throws JSONException, IOException, InterruptedException{

		JSONObject obj = new JSONObject();
		obj.put("result", "success");
		return obj.toString();
	}

	/*// save uploaded file to a defined location on the server
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

	}*/

	@POST
	@Path("/personfound")
	@Consumes(MediaType.MULTIPART_FORM_DATA)
	@Produces(MediaType.APPLICATION_JSON)
	public String personFound(@FormDataParam("personname") int personname, @FormDataParam("lat") String lat,
			@FormDataParam("long") String longitude) throws JSONException {

		//DummyDBNode node = db.getInfo(personid);
		System.out.println(personname + " found at location: " + lat + ", " + longitude);
		JSONObject obj = new JSONObject();
		obj.put("response", "success");
		return obj.toString();
	}

}
