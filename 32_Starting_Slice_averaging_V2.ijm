//Set threshold
IoU = 153;
//Set batch_size/Periodicity
batch_size = 32;

//Set directonary where offsets are saved (must be a directionary that only contains the offsets)
#@ File (style="directory") imageFolder;
dir = File.getDefaultDir;
dir = replace(dir,"\\","/");

files = getFileList(dir);
length = lengthOf(files);

waitForUser("original image length","click on the original image from which the offsets were created");
rename("original");
original_slices = nSlices;
close("original");

offset = 0;
for (n=0;n<length;n++){
	file = dir + files[n];
	open(file);
	rename("new_stack");
	amount_slices = nSlices;
    end_slice_keeper = amount_slices - batch_size + 1;
	run("Slice Keeper", "first=1 last=end_slice_keeper increment=1");
	rename("new_stack2");
	close("new_stack");
	all_slices = nSlices;
	offset_slices = all_slices - original_slices;
	begin_slice_keeper = 1 + offset_slices;
	run("Slice Keeper", "first=begin_slice_keeper last=all_slices increment=1");
	close("new_stack2");
	run("Divide...", "value=batch_size stack");
	title = "offset=" + offset;
	title_stack = "stack=" + offset;
	if (offset == 0){
		rename(title_stack);
	}
	if (offset > 0){
		rename(title);
		imageCalculator("Add create stack", title_stack,title); 
	}
	rename("stack=" + offset+1);
	close("new_stack");
	close(title);
	close(title_stack);
	offset += 1;
}

//Get image dimensions
w = getWidth();
h = getHeight();

for (i=0;i<nSlices;i++){
	//Loop for every pixel in current slice
	for (x=0;x<w;x++){
		for (y=0;y<h;y++){
			if (getPixel(x,y) > IoU){
				setPixel(x,y,255);
			} else {
				setPixel(x,y,0);
			}
		}
	}
	//Go to next slice and update slice number 
	run("Next Slice [>]");
}
waitForUser("Progress","Done");