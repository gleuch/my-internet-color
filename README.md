# My Internet Color

**A WOrK iN PROgrESs. pArDOn fOR MY MeSS**
*more info soon!*



#### Stealing History

You can pull info from the Chrome `History` sqlite file to add.

sqlite query, change [[timestamp]]: `select urls.url,visits.visit_time from visits left join urls on visits.url=urls.id where visit_time > [[timestamp]];`

convert into an array (regexp, etc) and run the following in irb (`bundle exec irb -r ./config.rb`):

`n.each do |v|
  begin
    t = Time.at(v[1]/1000000-11644473600) # convert from crazy pre-internet timestamp because like srsly omg
    BrowseHistory.add(v[0]).update_column(:created_at, t)
  rescue => err
    puts "ERR #{err} - #{v.inspect}"
  end
end`




(C) 2014 Greg Leuch. http://gleu.ch

Related: http://whatcolor.istheinter.net