// mongodb script that removes duplicates
var previous_slug;
print("Removing duplicates");
db.bills.find( {"slug" : {$exists:true} }, {"slug" : 1} ).sort( { "slug" : 1} ).forEach( function(current) {

  if(current.slug == previous_slug){
    print("Removing duplicate " + current.slug);
    db.bills.remove({_id:current._id});
  }

  previous_slug = current.slug;
});
