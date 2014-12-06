package com.findmissing.db;

import java.util.HashMap;

/**
 * Creates a dummy database with no sql queryies, just a dirty implementation as
 * I don't want to setup mysql :P
 * @author ankur
 *
 */
public class DummyDB {

	HashMap<Long, DummyDBNode> dbmap = new HashMap<Long, DummyDBNode>();

	public void insertUpdate(long pid, DummyDBNode node){
		dbmap.put(pid, node);
	}

	public DummyDBNode getInfo(long pid) {
		return dbmap.get(pid);
	}

}
