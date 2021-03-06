require 'koala'
require 'ruby-progressbar'

# TODO: Don't use hardcoded tokens
app_token = '1026238860854081|fvTV03tYC4zTMrZ-TbvZORzUjMg'
@client = Koala::Facebook::API.new(app_token)
filename = Time.now.getutc.to_s + '.csv'
output = File.open('output/' + filename, 'w')

def page_posts(page_id, limit)
  @client.get_connections(page_id, 'posts', {limit: limit, fields:['type']})
end

def photo_tags(post_id)
  begin
    @client.get_connections(post_id, 'tags', {fields: ['id']})
  rescue
    # not all photos have tags resource.
    # Sometimes Facbeook will return [], sometimes raise an Exception. Go figure.
    []
  end
end

def post_reactions(post_id)
    @client.get_connections(post_id, 'reactions')
end

def post_comments(post_id)
  @client.get_connections(post_id, 'comments')
end

STDIN.each_line do |line|
  page_id, limit = line.strip.split(',')
  progressbar = ProgressBar.create(format: 'Fetching posts %c/%C |%b>%i|', length: 80, total: limit.to_i)

  page_posts(page_id, limit).each do |post|
    progressbar.increment
    common_info = "#{page_id},#{post['id'].split('_')[1]},#{post['type']}"

    # Get reactions
    post_reactions(post['id']).each do |reaction|
      output.write("#{reaction['id']},#{common_info},reaction,#{reaction['type']}\n")
    end

    # Get comments
    post_comments(post['id']).each do |comment|
      output.write("#{comment['from']['id']},#{common_info},comment\n")
    end

    # If a post is a photo, look for tags
    if post['type'] == 'photo'
      photo_tags(post['id'].split('_')[1]).each do |tag|
        output.write("#{tag['id']},#{common_info},tag\n")
      end
    end
  end
  progressbar.finish
end
