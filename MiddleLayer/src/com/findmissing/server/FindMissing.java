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
import java.util.ArrayList;

import javax.imageio.ImageIO;
import javax.ws.rs.Consumes;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;

import matlabcontrol.MatlabConnectionException;
import matlabcontrol.MatlabInvocationException;
import matlabcontrol.MatlabProxy;
import matlabcontrol.MatlabProxyFactory;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.findmissing.db.DummyDB;
import com.findmissing.db.DummyDBNode;
import com.findmissing.db.DummyDataHelper;
import com.sun.jersey.core.header.FormDataContentDisposition;
import com.sun.jersey.multipart.FormDataParam;

@Path("/findmissing")
public class FindMissing {

	static String apacheDest = "D:/Program Files (x86)/Apache Software Foundation/Apache2.2/htdocs/jquery.facedetection/";

	static long requestid = 0;

	static DummyDB db;

	static {
		db = new DummyDB();
		DummyDataHelper.insertDummyData(1000, db);
		MatlabProxyFactory factory = new MatlabProxyFactory();
	    MatlabProxy proxy;
		try {
			proxy = factory.getProxy();
			proxy.eval("disp('hello world')");

		    //Disconnect the proxy from MATLAB
		    proxy.disconnect();
		} catch (MatlabConnectionException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (MatlabInvocationException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

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
			@FormDataParam("name") String personName)
			throws JSONException, IOException, InterruptedException {

		System.out.println(personName);
		// String filePath = contentDispositionHeader.getFileName();
		String imageName = "test" + requestid + ".jpg";
		String htmlfile = "test" + requestid + ".html";
		BufferedImage imBuff = ImageIO.read(fileInputStream);
		double scaleFactor = 0.4;
		imBuff = scale(imBuff, imBuff.getType(), (int)(imBuff.getWidth()*scaleFactor),
				(int)(imBuff.getHeight()*scaleFactor), scaleFactor, scaleFactor);
		File outI = new File(apacheDest + imageName);
		ImageIO.write(imBuff, "jpg", outI);
		//saveFile(fileInputStream, apacheDest + imageName);
		createHTML(apacheDest + htmlfile, imageName);
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
		delete(apacheDest + htmlfile);
		//delete(apacheDest + imageName);
		System.out.println(imageCrop);
		JSONArray jsonArray = new JSONArray();

		int resulttoreturn = 3;
		obj.put("requestid", requestid - 1);
		obj.put("response", "success");
		obj.put("matchesfound", resulttoreturn);
		obj.put("matchesinfo", jsonArray);

		for(int i = 0; i < resulttoreturn; i++){
			DummyDBNode node = db.getInfo(i);
			JSONObject match = new JSONObject();
			match.put("accuracy", 80);
			match.put("personid", i);
			ArrayList<String> images = node.getImages();
			int nimages = Math.min(images.size(), 5);
			String []urls = new String[nimages];
			for(int j = 0; j < nimages; j++) {
				urls[j] = images.get(j);
			}
			match.put("images", urls);
			jsonArray.put(match);
		}
		return obj.toString();
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
		createHTML(apacheDest + "test1.html", "2.jpg");
		detectFace("test1.html");
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
	public String personFound(@FormDataParam("personid") int personid, @FormDataParam("lat") String lat,
			@FormDataParam("long") String longitude) throws JSONException {

		DummyDBNode node = db.getInfo(personid);
		System.out.println(node.getPersonName() + " found at location: " + lat + ", " + longitude);
		JSONObject obj = new JSONObject();
		obj.put("response", "success");
		return obj.toString();
	}

}
