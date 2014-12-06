package com.findme.activity;

import java.io.File;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;

import org.apache.http.HttpResponse;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.FileEntity;
import org.apache.http.entity.mime.MultipartEntity;
import org.apache.http.entity.mime.content.FileBody;
import org.apache.http.entity.mime.content.StringBody;

import android.content.Intent;
import android.net.Uri;
import android.net.http.AndroidHttpClient;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Environment;
import android.provider.MediaStore;
import android.support.v7.app.ActionBarActivity;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.Window;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.ImageView;


public class MainActivity extends ActionBarActivity {

	ImageButton capture = null;
	ImageView clickedPic = null;
	Button find = null;
    static Uri image = null;
    EditText name = null;
	
	View.OnClickListener bringCamera = new View.OnClickListener() {
		
		@Override
		public void onClick(View v) {
			dispatchTakePictureIntent();
		}
	};
	
	View.OnClickListener findPerson = new View.OnClickListener() {
		
		@Override
		public void onClick(View v) {
			
			File file = new File(image.getPath());
			(new AsyncHttpPostTask("http://192.168.43.50:8080/findmissing/rest/findmissing/findperson")).execute(file);
		}
	};
	
	public class AsyncHttpPostTask extends AsyncTask<File, Void, String> {

	    private String server;

	    public AsyncHttpPostTask(final String server) {
	        this.server = server;
	    }

	    @Override
	    protected String doInBackground(File... params) {
	        HttpClient http = AndroidHttpClient.newInstance("AndroidApp");
	        HttpPost post = new HttpPost(this.server);
	        MultipartEntity entity = new MultipartEntity();
	        try {
	        	entity.addPart("name", new StringBody(name.getText().toString()));
		        entity.addPart("image", new FileBody(params[0], "text/plain"));
		        post.setEntity(entity);
	            HttpResponse response = http.execute(post);
	            //Log.d("Response", response.getStatusLine());
	            // final String serverResponse = slurp(is);
	            //Log.d(TAG, "serverResponse: " + out.toString());
	        } catch (ClientProtocolException e) {
	            e.printStackTrace();
	        } catch (IOException e) {
	            e.printStackTrace();
	        }
	        return null;
	    }
	}
	
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        this.requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_main);
        
        capture = (ImageButton) findViewById(R.id.capture);
        capture.setOnClickListener(bringCamera);
        
        find = (Button) findViewById(R.id.find);
        find.setOnClickListener(findPerson);
        
        name = (EditText) findViewById(R.id.name);
        
        clickedPic = (ImageView) findViewById(R.id.clicked_pic);
    }
    
    static final int REQUEST_IMAGE_CAPTURE = 1;
    static final int REQUEST_TAKE_PHOTO = 1;
    public void dispatchTakePictureIntent() {
        Intent takePictureIntent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
     // Ensure that there's a camera activity to handle the intent
        if (takePictureIntent.resolveActivity(getPackageManager()) != null) {
            // Create the File where the photo should go
            File photoFile = null;
            try {
                photoFile = createImageFile();
                Log.d("Photo", photoFile.getPath());
            } catch (IOException ex) {
                // Error occurred while creating the File
               
            }
            // Continue only if the File was successfully created
            if (photoFile != null) {
            	image = Uri.fromFile(photoFile);
                takePictureIntent.putExtra(MediaStore.EXTRA_OUTPUT,
                        Uri.fromFile(photoFile));
                startActivityForResult(takePictureIntent, REQUEST_TAKE_PHOTO);
            }
        }
    }
    
    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == REQUEST_IMAGE_CAPTURE && resultCode == RESULT_OK) {
           /* Bundle extras = data.getExtras();
            Bitmap imageBitmap = (Bitmap) extras.get("data");
            find.setVisibility(View.VISIBLE);*/
            clickedPic.setImageURI(image);
        }
    }
    
    String mCurrentPhotoPath;

    private File createImageFile() throws IOException {
        // Create an image file name
        String timeStamp = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date());
        String imageFileName = "JPEG_" + timeStamp + "_";
        File storageDir = Environment.getExternalStoragePublicDirectory(
                Environment.DIRECTORY_PICTURES);
        File image = File.createTempFile(
            imageFileName,  /* prefix */
            ".jpg",         /* suffix */
            storageDir      /* directory */
        );

        // Save a file: path for use with ACTION_VIEW intents
        mCurrentPhotoPath = "file:" + image.getAbsolutePath();
        return image;
    }
    
    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.main, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();
        if (id == R.id.action_settings) {
            return true;
        }
        return super.onOptionsItemSelected(item);
    }
}
