require 'koala'
require 'ruby-progressbar'

app_token = '1026238860854081|fvTV03tYC4zTMrZ-TbvZORzUjMg'
@client = Koala::Facebook::API.new(app_token)
filename = Time.now.getutc.to_s + '.csv'
output = File.open('output/' + filename, 'w')

def page_posts(page_id, limit)
  @client.get_connections(page_id, 'posts', {limit: limit, fields:['type']})
end

def post_reactions(post_id)
  @client.get_connections(post_id, 'reactions')
end

def post_comments(post_id)
  @client.get_connections(post_id, 'comments')
end

STDIN.each_line do |line|
  page_id, limit = line.strip.split(',')
  progressbar = ProgressBar.create(format: 'Fetching posts %c/%C|%b>%i|', length: 80, total: limit.to_i)

  page_posts(page_id, limit).each do |post|
    progressbar.increment
    common_info = "#{page_id},#{post['id'].split('_')[1]},#{post['type']}"

    post_reactions(post['id']).each do |reaction|
      output.write("#{reaction['id']},#{common_info},reaction,#{reaction['type']}\n")
    end

    post_comments(post['id']).each do |comment|
      output.write("#{comment['from']['id']},#{common_info},comment\n")
    end
  end
  progressbar.finish
end
