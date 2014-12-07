package com.findmissing.db;

import java.util.ArrayList;

public class DummyDBNode {
	long personid;
	ArrayList<String> images;
	String personName;
	String contactinfo;

	public DummyDBNode() {
		images = new ArrayList<String>();
	}

	public ArrayList<String> getImages(){
		return images;
	}

	public long getPersonid() {
		return personid;
	}

	public void setPersonid(long personid) {
		this.personid = personid;
	}

	public String getPersonName() {
		return personName;
	}

	public void setPersonName(String personName) {
		this.personName = personName;
	}

	public String getContactinfo() {
		return contactinfo;
	}

	public void setContactinfo(String contactinfo) {
		this.contactinfo = contactinfo;
	}

	public void setImages(ArrayList<String> images) {
		this.images = images;
	}

}
