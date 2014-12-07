function im=run_face_matcher(img)

fm = FaceMatcher();
im=fm.match(img);

end
