package com.findme.activity;

import java.io.File;

import org.json.JSONException;
import org.json.JSONObject;

import android.os.Bundle;
import android.support.v7.app.ActionBarActivity;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.Window;
import android.widget.Button;
import android.widget.GridView;

import com.findme.activity.MainActivity.AsyncHttpPostTask;
import com.findme.adapter.ImageListAdapter;

public class ImageListActivity extends ActionBarActivity {
	
	ImageListAdapter listAdapter = null;
	GridView imageListView = null;
	Button noMatch = null;
	
	View.OnClickListener no_match = new View.OnClickListener() {

		@Override
		public void onClick(View v) {
			ImageListActivity.this.finish();
			ImageListActivity.this.overridePendingTransition(android.R.anim.slide_in_left, android.R.anim.slide_out_right);
		}
	};

	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		this.requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.activity_image_list);
		
		String jsonString = getIntent().getStringExtra("jsonString");
		String prefix = getIntent().getStringExtra("prefix");
		
		Log.d("JSON", jsonString);
		
		JSONObject jsonObject = null;
		try {
			jsonObject = new JSONObject(jsonString);
			listAdapter = new ImageListAdapter(jsonObject.getJSONArray("matchesinfo"), getLayoutInflater(), this, prefix);
		} catch (JSONException e) {
			e.printStackTrace();
		}
		
		imageListView = (GridView) findViewById(R.id.imgListView);
		imageListView.setAdapter(listAdapter);
		
		noMatch = (Button) findViewById(R.id.noMatch);
		noMatch.setOnClickListener(no_match);
		
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.image_list, menu);
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
