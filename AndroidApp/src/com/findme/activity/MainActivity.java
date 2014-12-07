package com.findme.activity;

import java.io.File;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;

import org.apache.http.HttpResponse;
import org.apache.http.ParseException;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.mime.MultipartEntity;
import org.apache.http.entity.mime.content.FileBody;
import org.apache.http.entity.mime.content.StringBody;
import org.apache.http.util.EntityUtils;
import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.database.Cursor;
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
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.ImageView;

public class MainActivity extends ActionBarActivity {

	ImageButton capture = null;
	ImageView clickedPic = null;
	ImageButton find = null;
	ImageButton gallery = null;
	static Uri image = null;
	String prefix = null;
	HttpClient http = null;
	AlertDialog.Builder builder = null;
	ProgressDialog dialog = null;
	Context context = null;
	
	public static final int GET_FROM_GALLERY = 3;
	static final int REQUEST_IMAGE_CAPTURE = 1;
	static final int REQUEST_TAKE_PHOTO = 1;

	View.OnClickListener showGallery = new View.OnClickListener() {

		@Override
		public void onClick(View v) {
			startActivityForResult(new Intent(Intent.ACTION_PICK, android.provider.MediaStore.Images.Media.INTERNAL_CONTENT_URI), GET_FROM_GALLERY);
		}
	};
	
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
			(new AsyncHttpPostTask(prefix + "rest/findmissing/findperson"))
					.execute(file);
		}
	};

	public class AsyncHttpPostTask extends AsyncTask<File, Void, String> {

		private String server;
		private boolean isError = false;
		AlertDialog dialogMessage = null;

		public AsyncHttpPostTask(final String server) {
			this.server = server;
		}

		@Override
		protected void onPreExecute() {
			dialogMessage = builder.setMessage("No face detected. Please try again.")
					.setTitle("Error")
					.setNeutralButton("OK",
							new DialogInterface.OnClickListener() {
								public void onClick(DialogInterface dialog,
										int which) {
									dialog.cancel();
								}
							}).create();
			
			dialog = ProgressDialog.show(context, "Loading", "Please wait...", true);
			
			super.onPreExecute();

		}

		@Override
		protected String doInBackground(File... params) {
			HttpPost post = new HttpPost(this.server);
			MultipartEntity entity = new MultipartEntity();
			try {
				entity.addPart("name",
						new StringBody(params[0].getName()));
				entity.addPart("image", new FileBody(params[0], "text/plain"));
				post.setEntity(entity);
				
				HttpResponse response = http.execute(post);
				Intent intent = new Intent(MainActivity.this,
						ImageListActivity.class);
				String jsonStr = EntityUtils.toString(response.getEntity());
				JSONObject json = new JSONObject(jsonStr);
				if (json.getString("response").equalsIgnoreCase("error")) {
					isError = true;
				} else {
					if (json.getInt("matchesfound") != 0) {
						intent.putExtra("jsonString",
								jsonStr);
						intent.putExtra("prefix", prefix);
						
						startActivity(intent);
					} else 
						isError = true;
				}
				// final String serverResponse = slurp(is);
				// Log.d(TAG, "serverResponse: " + out.toString());
			} catch (ClientProtocolException e) {
				e.printStackTrace();
			} catch (IOException e) {
				e.printStackTrace();
			} catch (ParseException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} finally {
				post.abort();
			}
			return null;
		}
		
		@Override
		protected void onPostExecute(String result) {
			if (dialog.isShowing())
				dialog.cancel();
			if (isError) {
				dialogMessage.show();
			}
			super.onPostExecute(result);
		}
	}

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		this.requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.activity_main);

		capture = (ImageButton) findViewById(R.id.capture);
		capture.setOnClickListener(bringCamera);
		
		gallery = (ImageButton) findViewById(R.id.gallery);
		gallery.setOnClickListener(showGallery);

		find = (ImageButton) findViewById(R.id.find);
		find.setOnClickListener(findPerson);

		clickedPic = (ImageView) findViewById(R.id.clicked_pic);

		prefix = "http://192.168.43.71:8080/findmissing/";
		http = AndroidHttpClient.newInstance("AndroidApp");
		
		builder = new AlertDialog.Builder(this);
		
		context = MainActivity.this;
	}

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
			/*
			 * Bundle extras = data.getExtras(); Bitmap imageBitmap = (Bitmap)
			 * extras.get("data"); find.setVisibility(View.VISIBLE);
			 */
			clickedPic.setImageURI(image);
			find.setVisibility(View.VISIBLE);
		} else if (requestCode == GET_FROM_GALLERY
				&& resultCode == Activity.RESULT_OK) {
			image = Uri.parse(getRealPathFromURI(context, data.getData()));
			Log.d("Path", image.getPath());
			clickedPic.setImageURI(image);
			find.setVisibility(View.VISIBLE);
		}
	}
	
	public String getRealPathFromURI(Context context, Uri contentUri) {
		Cursor cursor = null;
		try {
			String[] proj = { MediaStore.Images.Media.DATA };
			cursor = context.getContentResolver().query(contentUri, proj, null,
					null, null);
			int column_index = cursor
					.getColumnIndexOrThrow(MediaStore.Images.Media.DATA);
			cursor.moveToFirst();
			return cursor.getString(column_index);
		} finally {
			if (cursor != null) {
				cursor.close();
			}
		}
	}

	String mCurrentPhotoPath;

	private File createImageFile() throws IOException {
		// Create an image file name
		String timeStamp = new SimpleDateFormat("yyyyMMdd_HHmmss")
				.format(new Date());
		String imageFileName = "JPEG_" + timeStamp + "_";
		File storageDir = Environment
				.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES);
		File image = File.createTempFile(imageFileName, /* prefix */
				".jpg", /* suffix */
				storageDir /* directory */
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
