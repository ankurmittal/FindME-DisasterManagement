package com.findme.adapter;

import java.io.IOException;
import java.io.InputStream;
import java.net.URL;

import org.apache.http.HttpResponse;
import org.apache.http.ParseException;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.mime.MultipartEntity;
import org.apache.http.entity.mime.content.StringBody;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.location.Criteria;
import android.location.Location;
import android.location.LocationManager;
import android.net.http.AndroidHttpClient;
import android.os.AsyncTask;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageButton;

import com.findme.activity.ImageListActivity;
import com.findme.activity.R;

public class ImageListAdapter extends BaseAdapter {
	/** The inflator used to inflate the XML layout */
	private LayoutInflater inflator;

	/** A list containing some sample data to show. */
	private JSONArray dataList;

	ImageListActivity mainAct;
	
	String prefix = null;
	static int count = 0;
	HttpClient http = null;
	LocationManager locationManager = null;
	public ImageListAdapter(JSONArray list, LayoutInflater inflator,
			ImageListActivity mainAct, String prefix) {
		super();
		this.inflator = inflator;
		this.mainAct = mainAct;
		dataList = list;
		this.prefix = prefix;
		this.http = AndroidHttpClient.newInstance("AndroidApp");
		locationManager = (LocationManager) mainAct.getSystemService(Context.LOCATION_SERVICE);
	}

	@Override
	public int getCount() {
		return dataList.length();
	}

	@Override
	public Object getItem(int position) {
		try {
			return dataList.get(position);
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return null;
	}

	@Override
	public long getItemId(int position) {
		return position;
	}

	@Override
	public View getView(int position, View view, ViewGroup viewGroup) {

		// We only create the view if its needed
		if (view == null) {
			view = inflator.inflate(R.layout.image_list_child, null);
			// Set the click listener for the checkbox
			// view.findViewById(R.id.isSelectedCheckBox).setOnClickListener(this);
		} else
			return view;
		final JSONObject personInfo = (JSONObject) getItem(position);
		String imgUrl = null;
		try {
			imgUrl = prefix + personInfo.getJSONArray("images").getString(0);
		} catch (JSONException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}
		Log.d("image", imgUrl);
		count++;
		Log.d("Result", String.valueOf(count));
		ImageButton img = (ImageButton) view.findViewById(R.id.appImageView1);
		URL url;
		Bitmap bmp = null;
		(new DownloadImageTask(img)).execute(imgUrl);
		
		img.setOnClickListener(new View.OnClickListener() {

	        @Override
	        public void onClick(View v) {
	            try {
					(new AsyncHttpPostTask(prefix)).execute(personInfo.getInt("personid"));
				} catch (JSONException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
	        }
		});
		return view;
	}
	
	public class AsyncHttpPostTask extends AsyncTask<Integer, Void, String> {

	    private String server;

	    public AsyncHttpPostTask(final String server) {
	        this.server = server;
	    }

	    protected String doInBackground(Integer... params) {
	        HttpPost post = new HttpPost(this.server + "rest/findmissing/personfound");
	        MultipartEntity entity = new MultipartEntity();
	        try {
	        	Log.d("params", String.valueOf(params[0]) );
	        	entity.addPart("personid", new StringBody( String.valueOf(params[0]) ));
	        	// Get the location manager
	        	
	            // Define the criteria how to select the locatioin provider -> use
	            // default
	            Criteria criteria = new Criteria();
	            String provider = locationManager.getBestProvider(criteria, false);
	            Location location = locationManager.getLastKnownLocation(provider);
	            Log.d("lat", String.valueOf(location.getLatitude()));
	            entity.addPart("lat", new StringBody( String.valueOf(location.getLatitude()) ));
	            entity.addPart("long", new StringBody( String.valueOf(location.getLongitude()) ));
	        	post.setEntity(entity);
	        	HttpResponse response = http.execute(post);
	        } catch (ClientProtocolException e) {
	            e.printStackTrace();
	        } catch (IOException e) {
	            e.printStackTrace();
	        } catch (ParseException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} finally {
				post.abort();
			}
	        return null;
	    }

		protected String doInBackground(String... params) {
			// TODO Auto-generated method stub
			return null;
		}
	}
	
	private class DownloadImageTask extends AsyncTask<String, Void, Bitmap> {
		ImageButton bmImage;

		  public DownloadImageTask(ImageButton bmImage) {
		      this.bmImage = bmImage;
		  }

		  protected Bitmap doInBackground(String... urls) {
		      String urldisplay = urls[0];
		      Bitmap mIcon11 = null;
		      try {
		        InputStream in = new java.net.URL(urldisplay).openStream();
		        mIcon11 = BitmapFactory.decodeStream(in);
		      } catch (Exception e) {
		          Log.e("Error", e.getMessage());
		          e.printStackTrace();
		      }
		      return mIcon11;
		  }

		  protected void onPostExecute(Bitmap result) {
		      bmImage.setImageBitmap(result);
		  }
		}

}
