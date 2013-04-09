library(stringr)

master.df = read.csv("data/faa-registry-20130408/MASTER.txt.bz2", quote="", stringsAsFactors=F)
master.df$X = NULL

colnames(master.df)[1] = 'n.number'
colnames(master.df) = tolower(colnames(master.df))

master.df = transform(master.df,
                      n.number = paste('N', str_trim(n.number), sep=''),
                      serial.number = str_trim(serial.number),
                      name = str_trim(name)
                    )


acref.df = read.csv("data/faa-registry-20130408/ACFTREF.txt.bz2", quote="", stringsAsFactors=F)

acref.df$X = NULL
colnames(acref.df)[1] = 'code'
colnames(acref.df) = tolower(colnames(acref.df))

acref.df = transform(acref.df,
                      mfr = str_trim(mfr),
                      model = str_trim(model)
                     )


master.df = merge(master.df, acref.df, by.x='mfr.mdl.code', by.y='code')

# master.df$model.code = gsub('^(\\S+)-.*', '\\1', master.df$model)

lookup.df = master.df[,c('n.number', 'mfr', 'model')]

write.csv(lookup.df, file="data/lookup.csv", row.names=F)
save(list=c('lookup.df'), file="data/lookup.df.RData")
