# coding: utf-8
# diff reverse zone between ns0x.idcf.jp and ns0x.idcfcloud.com
# snumano 2015/08/18

zone_file = "zone.txt"
arr_ns   = ["ns01.idc.jp", "ns01.idcfcloud.com",""]
arr_file = ["Result/ManagedDNS.txt", "Result/IDCFCloudDNS.txt","Result/default_out.txt"]

arr_ns.each_with_index{|ns, i|
  p i
  puts ns
  out_file = open("#{arr_file[i]}","w") 
  in_file = open(zone_file)
  in_file.each { |zone|
    puts zone
    zone.chomp!
    if i==2
      r = `/usr/bin/dig +noall +answer ns #{zone}`
    else
      r = `/usr/bin/dig +noall +answer ns #{zone} @#{ns}`
    end
    r.split("\n").each{|each|
      each =~ %r{^(.+.in-addr.arpa.).*NS\s*(\S+)$}
      out_file.puts $~[1] + "\t<NS>\t" + $~[2]
    }
    (0..255).each{|num|
      print "."
      STDOUT.flush
      if i==2
        r =`/usr/bin/dig +noall +answer ptr #{num.to_s}.#{zone}`
      else
        r =`/usr/bin/dig +noall +answer ptr #{num.to_s}.#{zone} @#{ns}`
      end
      unless r.empty?
#        p r
        r.split("\n").sort.each{|each|
          each =~ %r{^(.+.in-addr.arpa.).*PTR\s*(\S+)$}
          out_file.puts $~[1] + "\t" + $~[2]
        }
      end
    }
    puts # STDOUTに改行を挿入。見やすくするため
#    sleep(3)    
  }
  in_file.close
  out_file.close
}
